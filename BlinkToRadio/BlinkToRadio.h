#ifndef BLINKTORADIO_H
#define BLINKTORADIO_H

static const char *places[4] = {"ROOM", "KITCHEN", "BEDROOM", "YARD"};

enum {
  AM_BLINKTORADIO = 6,
  TIMER_PERIOD_MILLI = 10
};

typedef nx_struct BlinkToRadioMsg {
  nx_uint16_t nodeid;
  nx_uint8_t msg[8];
  nx_uint16_t counter;
  nx_uint16_t temp;
} BlinkToRadioMsg;

typedef nx_struct MsgStore {
  nx_uint8_t msg[8][100];
  nx_uint16_t temp[100];
  nx_uint16_t counter;
} MsgStore;


#endif