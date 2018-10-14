/*
 * packet_structures.h
 *
 *  Created on: 02.10.2018
 *      Author: caput
 */

#ifndef SRC_PACKET_STRUCTURES_H_
#define SRC_PACKET_STRUCTURES_H_

typedef enum
{
	CONTROL = 0,
	SPI = 1,
	AUDIO = 2,
	HDMI = 3
}packet_type_t;

typedef struct __attribute__((__packed__))
{
	packet_type_t type;
	u16 packet_id;
	u16 packets_left;
	u16 payload_size;
	u8 payload[3];
}packet_t;

typedef union
{
	packet_t packet;
	u8 *raw_data;
}data_t;


#endif /* SRC_PACKET_STRUCTURES_H_ */
