#include <Timer.h>
#include <string.h>
#include <time.h>
#include <stdlib.h>
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
  MsgStore store;
  uint8_t i;
  FILE *fp;

  event void Boot.booted() {
    dbg("BlinkToRadioC", "Application booted.\n");
    call AMControl.start();
    srand(time(NULL));
    fp = fopen("measures.csv", "w");
    if (fp == NULL) {
      printf("Error opening file!\n");
      exit(1);
    }
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
    if (counter > 2 && TOS_NODE_ID == 0) {
      // Timer0.stop();
      // AMControl.stop();
      dbg("BlinkToRadioC", "Store(%d):\n", store.counter);
      for (i = 0; i < store.counter; ++i) {
        dbg("BlinkToRadioC", "%s | %d\n", store.msg[i], store.temp[i]);
        fprintf(fp, "%s,%d\n", store.msg[i], store.temp[i]);
      }
      exit(0);
    }
    if (!busy && TOS_NODE_ID != 0) {
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof (BlinkToRadioMsg)));
      btrpkt->nodeid = TOS_NODE_ID;
      btrpkt->counter = counter;
      dbg("BlinkToRadioC", "place = %s.\n", places[TOS_NODE_ID - 1]);
      strcpy(btrpkt->msg, places[TOS_NODE_ID - 1]);
      btrpkt->temp = (rand() % (30 - 10 + 1)) + 10;
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
      dbg("BlinkToRadioC", "Received message: %s with temp %d from node %d.\n", btrpkt->msg, btrpkt->temp, btrpkt->nodeid);
      call Leds.set(btrpkt->counter);
      if (TOS_NODE_ID == 0 && store.counter < 100) {
        strcpy(store.msg[store.counter], btrpkt->msg);
        store.temp[store.counter] = btrpkt->temp;
        store.counter++;
        // dbg("BlinkToRadioC", "Store(%d):\n", store.counter);
        // for (i = 0; i < store.counter; ++i) {
        //   dbg("BlinkToRadioC", "%s | %d\n", store.msg[i], store.temp[i]);
        //   fprintf(fp, "%s,%d\n", store.msg[i], store.temp[i]);
        // }
      }
    }
    return msg;
  }
}