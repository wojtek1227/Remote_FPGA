/*
 * spi_thread.c
 *
 *  Created on: 03.09.2018
 *      Author: caput
 */
#include "spi_thread.h"
#include "stdbool.h"
#include "grabber_registers_addr.h"
#include "FreeRTOS.h"
#include "queue.h"

#define SPI_THREAD_STACKSIZE 1024
static XSpiPs spi;


QueueHandle_t spi_queue;
extern QueueHandle_t tcp_queue;

void InitSPI(void)
{
	XSpiPs_Config* config = XSpiPs_LookupConfig(0);
	XSpiPs_CfgInitialize(&spi, config, config->BaseAddress);
	XSpiPs_SetOptions(&spi, 0x0002FC0F);
	XSpiPs_SetClkPrescaler(&spi,4);
}

XSpiPs* GetSPIHandle(void)
{
	return &spi;
}

void spi_read_all_outputs(u8 * data)
{
	u8 write_buffer[3];
	u8 read_buffer[3];
	write_buffer[0] = READ;
	write_buffer[1] = RO_MEM_ADDR_START;
	write_buffer[3] = 0;
	for(u8 i = 0; i < RO_MEM_ADDR_END - RO_MEM_ADDR_START; i++)
	{

		XSpiPs_PolledTransfer(&spi, write_buffer, &read_buffer, 3);
		data[8 + i * 2] = read_buffer[2];
//		xil_printf("data i:%d data: %02X\r\n", i, data[8 + i * 2]);
		write_buffer[1] += 1;
	}
}

void spi_thread(void *p)
{
	volatile u8 x;
	xil_printf("Start spi thread\r\n");
	u8 data[] =
	{
			0x01, 0x0,
			0x0,  0x0,
			0x0,  0x0,
			0x16,
			0x80, 0x4,
			0x81, 0xf,
			0x82, 0xf0,
			0x83, 0x4f,
			0x84, 0x38,
			0x85, 0x30,
			0x86, 0x60,
			0x87, 0x42,
			0x88, 0x8,
			0x89, 0x30,
			0x8a, 0x42
	};
	u8 command[3];
	u8 data_rec[3];
	InitSPI();
	while(1)
	{

		x++;
//		xil_printf("Spi is alive\r\n");
		if(xQueueReceive(spi_queue, command, 0))
		{
//			xil_printf("Command %02X %02X %02X\r\n", command[0], command[1], command[2]);
			if(command[0] == 0x1)
			{
				spi_read_all_outputs(data);
				xQueueSend(tcp_queue, data, 0);
			}
			else
			{
				XSpiPs_PolledTransfer(GetSPIHandle(), command, &data_rec, 3);
			}

		}

//		vTaskDelay(1000/portTICK_PERIOD_MS);
	}
}

void spi_timer_callback(void *p)
{
	const u8 command[] = {0x1, 0, 0};
	xQueueSend(spi_queue, command, 0);
}

void start_spi_thread(void *p)
{
	sys_thread_new("SPI thread", spi_thread, (void *)p, SPI_THREAD_STACKSIZE);

}
