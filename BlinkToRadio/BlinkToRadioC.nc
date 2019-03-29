#include <Timer.h>
#include "BlinkToRadio.h"

module BlinkToRadioC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface SplitControl as AMControl;
  uses interface Receive;
}

implementation {
  bool busy = FALSE;
  message_t pkt;
  uint16_t counter = 0;

  event void Boot.booted() {
    dbg("BlinkToRadioC", "Application booted.\n");
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    } else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
  }

  event void Timer0.fired() {
    counter++;
    dbg("BlinkToRadioC", "BlinkToRadioC: timer fired, counter is %hu.\n", counter);
    if (!busy) {
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof (BlinkToRadioMsg)));
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->counter = counter;
      if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
        dbg("BlinkToRadioC", "BlinkToRadioC: packet sent.\n", counter);	
        busy = TRUE;
      }
    }
  }

  event void AMSend.sendDone(message_t* msg, error_t error) {
    if (&pkt == msg) {
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    dbg("BlinkToRadioC", "Time: %s\n", sim_time_string());
    dbg("BlinkToRadioC", "Received packet of length %hhu.\n", len);
    if (len == sizeof(BlinkToRadioMsg)) {
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
      call Leds.set(btrpkt->counter);
    }
    return msg;
  }
}