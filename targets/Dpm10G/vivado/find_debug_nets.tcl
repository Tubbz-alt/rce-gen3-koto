
set base {U_DpmCore/U_RceG3Top/U_RceG3Dma/U_PpiDmaGen.U_RceG3DmaPpi/U_PpiGen[3].U_PpiSocket/U_ObHeader}

set srcs {r[state]* r[dmaReq]* dmaAck* obPendMaster[tValid] obPendMaster[tLast] obPendSlave[tReady]}

set fp [open $::env(PROJ_DIR)/debug/find_log.txt w]

foreach src $srcs {
   set nets [split [get_nets $base/$src] " "]

   foreach net $nets {
      puts $fp "$net"
   }
}

close $fp
