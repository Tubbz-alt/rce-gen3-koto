-------------------------------------------------------------------------------
-- Title      : AXI Stream DMA Read
-- Project    : General Purpose Core
-------------------------------------------------------------------------------
-- File       : AxiStreamDmaReadKoto.vhd
-- Author     : Ryan Herbst, rherbst@slac.stanford.edu
-- Created    : 2014-04-25
-- Last update: 2016-10-27
--            : 2017-10-21  MT updates rMaster.arlen in FIRST_S as dmaReq.address LBS bits count and definition of reqCnt/ackCnt as number of DMA transfers 
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Block to transfer a single AXI Stream frame from memory using an AXI
-- interface.
-------------------------------------------------------------------------------
-- This file is part of 'SLAC Firmware Standard Library'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'SLAC Firmware Standard Library', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;
use work.AxiPkg.all;
use work.AxiDmaPkg.all;

entity AxiStreamDmaReadKoto is
   generic (
      TPD_G           : time                := 1 ns;
      AXIS_READY_EN_G : boolean             := false;
      AXIS_CONFIG_G   : AxiStreamConfigType := AXI_STREAM_CONFIG_INIT_C;
      AXI_CONFIG_G    : AxiConfigType       := AXI_CONFIG_INIT_C;
      AXI_BURST_G     : slv(1 downto 0)     := "01";
      AXI_CACHE_G     : slv(3 downto 0)     := "1111";
	  SW_CACHE_EN_G   : boolean             := false;
      PIPE_STAGES_G   : natural             := 1;
      PEND_THRESH_G   : natural             := 0;  -- In units of bytes
      BYP_SHIFT_G     : boolean             := false);      
   port (
      -- Clock/Reset
      axiClk        : in  sl;
      axiRst        : in  sl;
      -- DMA Control Interface 
      dmaReq        : in  AxiReadDmaReqType;
      dmaAck        : out AxiReadDmaAckType;
	  swCache       : in  slv(3 downto 0) := "0000";
      -- Streaming Interface 
      axisMaster    : out AxiStreamMasterType;
      axisSlave     : in  AxiStreamSlaveType;
      axisCtrl      : in  AxiStreamCtrlType;
      -- AXI Interface
      axiReadMaster : out AxiReadMasterType;
      axiReadSlave  : in  AxiReadSlaveType);
end AxiStreamDmaReadKoto;

architecture rtl of AxiStreamDmaReadKoto is

-- MT Added   
      signal reqstateProbe  : slv(1 downto 0);
      attribute mark_debug of reqstateProbe : signal is "true";
      signal stateProbe  : slv(2 downto 0);
      attribute mark_debug of stateProbe : signal is "true";
   
      signal axiReadMasterProbe: AxiReadMasterType;
      signal axisMasterProbe  : AxiStreamMasterType;
      signal dmaAckProbe : AxiReadDmaAckType;

      signal firstSizeProbe : slv(3 downto 0);
      signal readSizeProbe : slv(3 downto 0);
      signal pendingProbe  : sl;
      
      component ila_AxiStreamDmaRead
       PORT ( clk         : IN STD_LOGIC;
--              trig_in     : IN STD_LOGIC;
              probe0      : IN STD_LOGIC_VECTOR(299 DOWNTO 0) );
      end component;
-- end of MT added

   constant DATA_BYTES_C : integer         := AXIS_CONFIG_G.TDATA_BYTES_C;
   constant ADDR_LSB_C   : integer         := bitSize(DATA_BYTES_C-1);
   constant ARLEN_C      : slv(7 downto 0) := getAxiLen(AXI_CONFIG_G, 4096);

   type ReqStateType is (
      IDLE_S,
      FIRST_S,
      NEXT_S);

   type StateType is (
      IDLE_S,
      MOVE_S,
      LAST_S,
      DONE_S,
      BLOWOFF_S);      

   type RegType is record
      pendBytes : slv(31 downto 0);
      size      : slv(31 downto 0);
      reqSize   : slv(31 downto 0);
      reqCnt    : slv(31 downto 0);
      ackCnt    : slv(31 downto 0);
      dmaReq    : AxiReadDmaReqType;
      dmaAck    : AxiReadDmaAckType;
      shift     : slv(3 downto 0);
      shiftEn   : sl;
      first     : sl;
      leftovers : sl;
      rMaster   : AxiReadMasterType;
      sMaster   : AxiStreamMasterType;
      reqState  : ReqStateType;
      state     : StateType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      pendBytes => (others => '0'),
      size      => (others => '0'),
      reqSize   => (others => '0'),
      reqCnt    => (others => '0'),
      ackCnt    => (others => '0'),
      dmaReq    => AXI_READ_DMA_REQ_INIT_C,
      dmaAck    => AXI_READ_DMA_ACK_INIT_C,
      shift     => (others => '0'),
      shiftEn   => '0',
      first     => '0',
      leftovers => '0',
      rMaster   => axiReadMasterInit(AXI_CONFIG_G, AXI_BURST_G, AXI_CACHE_G),
      sMaster   => axiStreamMasterInit(AXIS_CONFIG_G),
      reqState  => IDLE_S,
      state     => IDLE_S);

   signal r          : RegType := REG_INIT_C;
   signal rin        : RegType;
   signal pause      : sl;
   signal sSlave     : AxiStreamSlaveType;
   signal pipeMaster : AxiStreamMasterType;
   signal pipeSlave  : AxiStreamSlaveType;
   signal mMaster    : AxiStreamMasterType;
   signal mSlave     : AxiStreamSlaveType;

   -- attribute dont_touch      : string;
   -- attribute dont_touch of r : signal is "TRUE";

begin

   assert AXIS_CONFIG_G.TDATA_BYTES_C = AXI_CONFIG_G.DATA_BYTES_C
      report "AXIS (" & integer'image(AXIS_CONFIG_G.TDATA_BYTES_C) & ") and AXI ("
      & integer'image(AXI_CONFIG_G.DATA_BYTES_C) & ") must have equal data widths" severity failure;

   pause <= '0' when (AXIS_READY_EN_G) else axisCtrl.pause;

   comb : process (axiReadSlave, axiRst, dmaReq, mMaster, mSlave, pause, r, sSlave, swCache) is
      variable v        : RegType;
      variable readSize : integer;
      variable firstSize: integer;
      variable reqLen   : natural;
      variable pending  : boolean;
   begin
      -- Latch the current value   
      v := r;

       -- Set cache value if enabled in software
      if SW_CACHE_EN_G then
         v.rMaster.arcache := swCache;
      end if;

      -- Reset strobing Signals
      v.rMaster.rready := '0';
      v.shiftEn        := '0';
      if (axiReadSlave.arready = '1') then
         v.rMaster.arvalid := '0';
      end if;
      if (sSlave.tReady = '1') then
         v.sMaster.tValid := '0';
         v.sMaster.tLast  := '0';
         v.sMaster.tUser  := (others => '0');
         v.sMaster.tKeep  := (others => '1');
         v.sMaster.tStrb  := (others => '1');
      end if;

      -- Calculate the pending bytes
      v.pendBytes := r.reqCnt - r.ackCnt;

      -- Update variables
      reqLen  := 0;
      pending := true;
      -- Check for the threshold = zero case
      if (PEND_THRESH_G = 0) then
         if (r.pendBytes = 0) then
            pending := false;
         end if;
      else
         if (r.pendBytes < PEND_THRESH_G) then
            pending := false;
         end if;
      end if;

      -- Track read status
      if (axiReadSlave.rvalid = '1') and (axiReadSlave.rresp /= 0) and (axiReadSlave.rlast = '1') then
         -- Error Detected
         v.dmaAck.readError  := '1';
         v.dmaAck.errorValue := axiReadSlave.rresp;
      end if;

      -- Check for handshaking
      if (dmaReq.request = '0') and (r.dmaAck.done = '1') then
         -- Reset the flags
         v.dmaAck.done := '0';
      end if;

      -- Memory Request State machine
      case r.reqState is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Update the variables
            v.dmaReq := dmaReq;
            -- Reset the counters
            v.shift  := (others => '0');
            v.reqCnt := (others => '0');
            v.ackCnt := (others => '0');
            -- Align shift and address to transfer size
            if (DATA_BYTES_C /= 1) then
               v.dmaReq.address(ADDR_LSB_C-1 downto 0) := (others => '0');
               v.shift(ADDR_LSB_C-1 downto 0)          := dmaReq.address(ADDR_LSB_C-1 downto 0);
            end if;
            -- Check for DMA request 
            if (dmaReq.request = '1') then
               -- Reset the flags and counters
               v.dmaAck.readError  := '0';
               v.dmaAck.errorValue := (others => '0');
               -- Set the flags
               v.shiftEn           := '1';
               v.first             := '1';
               -- Latch the value
               v.size              := dmaReq.size;
               v.reqSize           := dmaReq.size;
               v.sMaster.tDest     := dmaReq.dest;
               v.sMaster.tId       := dmareq.id;
               -- Next state
               v.reqState          := FIRST_S;
            end if;
         ----------------------------------------------------------------------
         when FIRST_S =>
            -- Check if ready to make memory request
            if (r.rMaster.arvalid = '0') then
               -- Set the memory address 
               v.rMaster.araddr(AXI_CONFIG_G.ADDR_WIDTH_C-1 downto 0) := r.dmaReq.address(AXI_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
               -- Determine transfer size to align address to 16-transfer boundaries
               -- This initial alignment will ensure that we never cross a 4k boundary
               if (ARLEN_C > 0) then
                  -- Set the burst length
                  v.rMaster.arlen := ARLEN_C - r.dmaReq.address(ADDR_LSB_C+AXI_CONFIG_G.LEN_BITS_C-1 downto ADDR_LSB_C);
                  -- Limit read burst size
                  if (r.reqSize(31 downto ADDR_LSB_C) < v.rMaster.arlen) then
                     v.rMaster.arlen := resize(r.reqSize(ADDR_LSB_C+AXI_CONFIG_G.LEN_BITS_C-1 downto ADDR_LSB_C)-1, 8);
-- MT                  if ((r.reqSize(ADDR_LSB_C downto 0)-1) < v.rMaster.arlen) then
-- MT                    firstSize := conv_integer(r.reqSize(ADDR_LSB_C downto 0));
-- MT                  v.rMaster.arlen := toSlv(firstSize-1, 8);
                  end if;
               end if;
               -- There is enough room in the FIFO for a burst
               if (pause = '0') then
                  -- Set the flag
                  v.rMaster.arvalid                       := '1';
                  -- Update the request size
                  reqLen                                  := DATA_BYTES_C*(conv_integer(v.rMaster.arlen) + 1);
                  v.reqCnt                                := toSlv(reqLen, 32) - conv_integer(r.shift);
                  v.reqSize                               := r.reqSize - reqLen;
-- MT                  v.reqCnt                                := toSlv(conv_integer(v.rMaster.arlen) + 1, 32) - conv_integer(r.shift);
-- MT                  v.reqSize                               := r.reqSize - r.reqCnt;
                  -- Update next address
                  v.dmaReq.address                        := r.dmaReq.address + reqLen;
                  v.dmaReq.address(ADDR_LSB_C-1 downto 0) := (others => '0');
                  -- Next state
                  v.reqState                              := NEXT_S;
                  v.state                                 := MOVE_S;
               end if;
            end if;
         ----------------------------------------------------------------------
         when NEXT_S =>
            -- Check if ready to make memory request
            if (r.rMaster.arvalid = '0') then
               -- Set the memory address          
               v.rMaster.araddr(AXI_CONFIG_G.ADDR_WIDTH_C-1 downto 0) := r.dmaReq.address(AXI_CONFIG_G.ADDR_WIDTH_C-1 downto 0);
               -- Bursts after the FIRST are guaranteed to be aligned
               v.rMaster.arlen                                        := ARLEN_C;
               -- Limit read burst size
               if (r.reqSize(31 downto ADDR_LSB_C) < v.rMaster.arlen) then
                 v.rMaster.arlen := resize(r.reqSize(ADDR_LSB_C+AXI_CONFIG_G.LEN_BITS_C-1 downto ADDR_LSB_C)-1, 8);
               end if;
               -- Check for the following:
               --    1) There is enough room in the FIFO for a burst 
               --    2) pending flag
               --    3) Last transaction already completed
               if (pause = '0') and (pending = false) and (r.reqCnt < r.dmaReq.size) then
-- MT               if (pause = '0') and (pending = false) and (r.reqCnt < r.reqSize) then  
                  -- Set the flag            
                  v.rMaster.arvalid                       := '1';
                  -- Update the request size
                  reqLen                                  := DATA_BYTES_C*(conv_integer(v.rMaster.arlen) + 1);
                  v.reqCnt                                := r.reqCnt + reqLen;
                  v.reqSize                               := r.reqSize - reqLen;
-- MT                  v.reqCnt                                := toSlv(conv_integer(v.rMaster.arlen) + 1, 32);
-- MT                  v.reqSize                               := r.reqSize - r.reqCnt;
                  -- Update next address
                  v.dmaReq.address                        := r.dmaReq.address + reqLen;
                  v.dmaReq.address(ADDR_LSB_C-1 downto 0) := (others => '0');
               end if;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Data Collection State machine
      case r.state is
         ----------------------------------------------------------------------
         when IDLE_S =>
            -- Blowoff any out-of-phase data (should never happen)
            v.rMaster.rready := '1';
         ----------------------------------------------------------------------
         when MOVE_S =>
            -- Check if ready to move data
            if (v.sMaster.tValid = '0') and (axiReadSlave.rvalid = '1') then
               -- Accept the data 
               v.rMaster.rready                             := '1';
               -- Move the data
               v.sMaster.tValid                             := '1';
               v.sMaster.tData((DATA_BYTES_C*8)-1 downto 0) := axiReadSlave.rdata((DATA_BYTES_C*8)-1 downto 0);
               -- Check the flag
               if r.first = '1' then
                  -- Reset the flag
                  v.first := '0';
--                  firstSize := 0;   -- bad!! Changes exactly when readSize is defined
                  -- Set the tUser for the first byte transferred
                  axiStreamSetUserField(
                     AXIS_CONFIG_G,
                     v.sMaster,
                     r.dmaReq.
                     firstUser(AXIS_CONFIG_G.TUSER_BITS_C-1 downto 0),
                     conv_integer(r.shift));
               end if;
               -- Calculate the read size
               readSize := DATA_BYTES_C - ite(r.first = '1', conv_integer(r.shift), 0);
-- MT               readSize := ite(r.first = '1', firstSize - conv_integer(r.shift), conv_integer(ARLEN_C)+1);  -- 
                -- Check the read size
               if (readSize > r.size) then
                  -- Bottom out at 0
                  v.size   := (others => '0');
                  -- Top out at dma.size
                  v.ackCnt := r.dmaReq.size;
               else
                  -- Decrement the counter
                  v.size   := r.size - readSize;
                  -- Increment the counter
                  v.ackCnt := r.ackCnt + readSize;
-- MT                  v.ackCnt := toSlv(readSize,32);
               end if;
               -- Check for completion 
               if (v.size = 0) then
                  -- Terminate the frame
                  v.sMaster.tLast := '1';
                  v.sMaster.tKeep := genTKeep(conv_integer(r.size(4 downto 0)));
                  v.sMaster.tStrb := genTKeep(conv_integer(r.size(4 downto 0)));
                  -- Check for first transfer
                  if (r.first = '1') then
                     -- Compensate the tKeep and tStrb via shift module
                     v.sMaster.tKeep := shl(v.sMaster.tKeep, r.shift);
                     v.sMaster.tStrb := shl(v.sMaster.tStrb, r.shift);
                  end if;
                  -- Set the flags
                  v.dmaAck.done := '1';
                  v.leftovers   := not(axiReadSlave.rlast);
                  -- Next state
                  v.state       := LAST_S;
               end if;
            end if;
         ----------------------------------------------------------------------
         when LAST_S =>
            -- Hold until last transfer (required for Remap_mAxisMaster process)
            if (mMaster.tValid = '1') and (mMaster.tLast = '1') and (mSlave.tReady = '1') then
               -- Next state
               v.state := DONE_S;
            end if;
         ----------------------------------------------------------------------
         when DONE_S =>
            -- Check for ACK completion 
            if (r.dmaAck.done = '0')then
               -- Reset the flag
               v.leftovers := '0';
               -- Check if no leftover memory request data
               if r.leftovers = '0' then
                  -- Next states
                  v.reqState := IDLE_S;
                  v.state    := IDLE_S;
               else
                  -- Next state
                  v.state := BLOWOFF_S;
               end if;
            end if;
         ----------------------------------------------------------------------
         when BLOWOFF_S =>
            -- Blowoff the data 
            v.rMaster.rready := '1';
            -- Check for last transfer
            if (axiReadSlave.rvalid = '1') and (axiReadSlave.rlast = '1') then
               -- Next states
               v.reqState := IDLE_S;
               v.state    := IDLE_S;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Forward the state of the state machine
      if v.state = IDLE_S then
         -- Set the flag
         v.dmaAck.idle := '1';
      else
         -- Reset the flag
         v.dmaAck.idle := '0';
      end if;

      -- Reset      
      if (axiRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle      
      rin <= v;

      -- Outputs         
--      dmaAck               <= r.dmaAck;
--      axiReadMaster        <= r.rMaster;
--      axiReadMaster.rready <= v.rMaster.rready;
      dmaAckProbe               <= r.dmaAck;
      axiReadMasterProbe        <= r.rMaster;
      axiReadMasterProbe.rready <= v.rMaster.rready;

      firstSizeProbe <= conv_std_logic_vector(firstSize, 4);
      readSizeProbe  <= conv_std_logic_vector(readSize, 4);
      pendingProbe <= toSl(pending);

   end process comb;

   seq : process (axiClk) is
   begin
      if (rising_edge(axiClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   U_Pipeline : entity work.AxiStreamPipeline
      generic map (
         TPD_G         => TPD_G,
         PIPE_STAGES_G => PIPE_STAGES_G)
      port map (
         axisClk     => axiClk,
         axisRst     => axiRst,
         sAxisMaster => r.sMaster,
         sAxisSlave  => sSlave,
         mAxisMaster => pipeMaster,
         mAxisSlave  => pipeSlave);     

   U_AxiStreamShift : entity work.AxiStreamShift
      generic map (
         TPD_G         => TPD_G,
         PIPE_STAGES_G => PIPE_STAGES_G,
         AXIS_CONFIG_G => AXIS_CONFIG_G,
         BYP_SHIFT_G   => BYP_SHIFT_G) 
      port map (
         axisClk     => axiClk,
         axisRst     => axiRst,
         axiStart    => r.shiftEn,
         axiShiftDir => '1',
         axiShiftCnt => r.shift,
         sAxisMaster => pipeMaster,
         sAxisSlave  => pipeSlave,
         mAxisMaster => mMaster,
         mAxisSlave  => mSlave);

   Remap_mAxisMaster : process (mMaster, r) is
      variable tmp : AxiStreamMasterType;
   begin
      -- Latch the current value
      tmp := mMaster;
      -- Check for tLast
      if mMaster.tLast = '1' then
         axiStreamSetUserField (AXIS_CONFIG_G, tmp, r.dmaReq.lastUser(AXIS_CONFIG_G.TUSER_BITS_C-1 downto 0));
      -- Note: This is done here (instead of "comb" process) to prevent a crazy long logic chain
      -- Note: For the "1 byte" case, lastUser will overwrite the firstUser value.
      end if;
      -- Outputs
--      axisMaster <= tmp;
      axisMasterProbe <= tmp;
   end process;

   mSlave <= axisSlave when(AXIS_READY_EN_G) else AXI_STREAM_SLAVE_FORCE_C;
   
-- MT added
    reqstateProbe <=    b"00" when rin.reqstate = IDLE_S else
                        b"01" when rin.reqstate = FIRST_S else
                        b"10" when rin.reqstate = NEXT_S else
                        b"11";

    stateProbe <=    b"000" when rin.state = IDLE_S else
                     b"001" when rin.state = MOVE_S else
                     b"010" when rin.state = LAST_S else
                     b"011" when rin.state = DONE_S else
                     b"100" when rin.state = BLOWOFF_S else
                     b"111";
   
    u_ila : ila_AxiStreamDmaRead
        port map (clk         => axiClk,
--                  trig_in     => dbgout,
              probe0(0) => axiRst,
              probe0(1) => axiReadSlave.arready,
              probe0(2) => axiReadSlave.rvalid,
              probe0(3) => axiReadSlave.rlast,
              probe0(67   downto 4) => axiReadSlave.rdata(63 downto 0),
              probe0(68) => axisSlave.tReady,
              probe0(69) => axisCtrl.pause,
              probe0(101  downto 70) => dmaReq.address(31 downto 0),
              probe0(117  downto 102) => dmaReq.size(15 downto 0),
              probe0(118) => dmaReq.request, 
              probe0(119) => dmaAckProbe.done, 
              probe0(135  downto 120) => rin.reqSize(15 downto 0),
              probe0(151  downto 136) => rin.size(15 downto 0),
              probe0(167  downto 152) => rin.reqCnt(15 downto 0),
              probe0(183  downto 168) => rin.ackCnt(15 downto 0),
              probe0(199  downto 184) => rin.pendBytes(15 downto 0),
              probe0(200) => rin.sMaster.tValid,
              probe0(201) => rin.sMaster.tLast,
              probe0(202) => pendingProbe,
              probe0(210  downto 203) => rin.rMaster.arlen(7 downto 0),
              probe0(212  downto 211) => reqStateProbe(1 downto 0),
              probe0(215  downto 213) => stateProbe(2 downto 0),
              probe0(216) => axisMasterProbe.tValid,
              probe0(217) => axisMasterProbe.tLast,
              probe0(249   downto 218) => axisMasterProbe.tData(31 downto 0),
              probe0(257   downto 250) => axiReadMasterProbe.arlen(7 downto 0),
              probe0(289   downto 258) => axiReadMasterProbe.araddr(31 downto 0),
              probe0(290) => axiReadMasterProbe.arvalid,
              probe0(291) => axiReadMasterProbe.rready,
              probe0(295 downto 292) => firstSizeProbe(3 downto 0),
              probe0(299 downto 296) => readSizeProbe(3 downto 0)
--              probe0(299  downto 296) => (others=>'0')
        );
 
        axiReadMaster  <= axiReadMasterProbe;
        axisMaster     <= axisMasterProbe;
        dmaAck         <= dmaAckProbe;
  
end rtl;
