#ifndef _GRABBER_REGISTERS_ADDR_H_
#define _GRABBER_REGISTERS_ADDR_H_


//Instructions
#define CLEAR 0xcd;
#define WRITE 0xad;
#define READ 0xed;

//Addresses
//RW registers
#define SW_DATA_LOW_ADDR 0x1;
#define SW_DATA_HIGH_ADDR 0x2;
#define SW_SELECT_LOW_ADDR 0x3;
#define SW_SELECT_HIGH_ADDR 0x4;
#define BTN_DATA_ADDR 0x5;
#define BTN_SELECT_ADDR 0x6;
//Control registers
#define CONTROL_REGISTER_ADDR 0x7;
//32bit display sampling counter overflow register Little endian addressing
//Byte 0 at 8'h7
//Byte 1 at 8'h8
//Byte 2 at 8'h9
//Byte 3 at 8'ha 
#define DISPLAY_SAMPLING_CNT_OVF_ADDR 0x8;
//32bit gpio sampling counter overflow register Little endian addressing
//Byte 0 at 8'hc
//Byte 1 at 8'hd
//Byte 2 at 8'he
//Byte 3 at 8'hf 
#define GPIO_SAMPLING_CNT_OVF_ADDR 0xc;
//Increment this address when adding new RW registers
#define RW_MEM_END_ADDR 0x10;

//RO registers
#define RO_MEM_START 0x80;
#define RGB_DATA_ADDR 0x80;
#define LED_DATA_LOW_ADDR 0x81;
#define LED_DATA_HIGH_ADDR 0x82;
#define DIGIT_0_DATA_ADDR 0x83;
#define DIGIT_1_DATA_ADDR 0x84;
#define DIGIT_2_DATA_ADDR 0x85;
#define DIGIT_3_DATA_ADDR 0x86;
#define DIGIT_4_DATA_ADDR 0x87;
#define DIGIT_5_DATA_ADDR 0x88;
#define DIGIT_6_DATA_ADDR 0x89;
#define DIGIT_7_DATA_ADDR 0x8a;

#define RO_MEM_ADDR_END 0x8c;


#endif /* _GRABBER_REGISTERS_ADDR_H_ */
