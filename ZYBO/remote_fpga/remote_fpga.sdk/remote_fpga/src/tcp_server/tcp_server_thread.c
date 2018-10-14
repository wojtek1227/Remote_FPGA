/******************************************************************************
*
* Copyright (C) 2018 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

#include "tcp_server_thread.h"

#include "../spi/spi_thread.h"
#include "../packet_structures.h"

extern struct netif server_netif;

void print_app_header(void)
{
	xil_printf("TCP server listening on port %d\r\n",
			TCP_CONN_PORT);
}

static void print_tcp_conn_stats(int sock)
{
#if LWIP_IPV6==1
	struct sockaddr_in6 local, remote;
#else
	struct sockaddr_in local, remote;
#endif /* LWIP_IPV6 */
	int size;

	size = sizeof(local);
	getsockname(sock, (struct sockaddr *)&local, (socklen_t *)&size);
	getpeername(sock, (struct sockaddr *)&remote, (socklen_t *)&size);
#if LWIP_IPV6==1
	xil_printf("Local %s port %d connected with ", inet6_ntoa(local.sin6_addr), ntohs(local.sin6_port));
	xil_printf("%s port %d\r\n", inet6_ntoa(remote.sin6_addr),
			ntohs(local.sin6_port));
#else
	xil_printf("Local %s port %d connected with ", inet_ntoa(local.sin_addr), ntohs(local.sin_port));
	xil_printf("%s port %d\r\n", inet_ntoa(remote.sin_addr), ntohs(local.sin_port));
#endif /* LWIP_IPV6 */
}

/* thread spawned for each connection */
void tcp_server_thread(void *p)
{
	char recv_buf[RECV_BUF_SIZE];
	static char thread_id;
	thread_id++;
	packet_t* recv;
	recv = (packet_t*) recv_buf;
	char data_rec[5];
	int read_bytes;
	volatile u8 x = 0;
	int sock = *((int *)p);
	InitSPI();
	print_tcp_conn_stats(sock);
	char data[] =
	{
			0x01, 0x0,
			0x0,  0x0,
			0x0,  0x0,
			0x16,
			0x80, 0x4,
			0x81, 0xf,
			0x82, 0xf0,
			0x83, 0xfe,
			0x84, 0xfd,
			0x85, 0xfb,
			0x86, 0xf7,
			0x87, 0xef,
			0x88, 0xdf,
			0x89, 0xbf,
			0x8a, 0x7f
	};
	const char led_low[] = { 0xed, 0x81, 0x00};
	const char led_high[] = { 0xed, 0x82, 0x00};
	xil_printf("Thread id %d\r\n", thread_id);
	while (1) {
//			data[12] = x;
//			data[14] = ~x;

//
			XSpiPs_PolledTransfer(GetSPIHandle(), led_low, &data_rec, 3);
			xil_printf("Spi led low %02X %02X %02X\r\n", data_rec[0], data_rec[1], data_rec[2]);
			data[10] = data_rec[2];
			XSpiPs_PolledTransfer(GetSPIHandle(), led_high, &data_rec, 3);
			xil_printf("Spi led high %02X %02X %02X\r\n", data_rec[0], data_rec[1], data_rec[2]);
			data[12] = data_rec[2];
			xil_printf("data12 %d data 14 %d\r\n", data[12], data[14]);
//			xil_printf("Writing %d \r\n", sizeof(data));
			x = lwip_write(sock, data, sizeof(data));
//			xil_printf("%d bytes written \r\n", x);
//			xil_printf("Running \r\n");
			if ((read_bytes = lwip_recvfrom(sock, recv_buf, RECV_BUF_SIZE,
					MSG_DONTWAIT, NULL, NULL)) > 0) {

				xil_printf("Received %02X %02X %02X\r\n", recv->payload[0], recv->payload[1], recv->payload[2]);
				XSpiPs_PolledTransfer(GetSPIHandle(), recv->payload, &data_rec, 3);
	//			lwip_write(sock, data_rec, read_bytes);
				xil_printf("Spi received %02X %02X %02X\r\n", data_rec[0], data_rec[1], data_rec[2]);
////				close(sock);
			}
			vTaskDelay(200/portTICK_PERIOD_MS);

	}

	/* close connection */
	close(sock);
	vTaskDelete(NULL);
}

void start_tcp_server_thread(void)
{
	int sock, new_sd;
#if LWIP_IPV6==1
	struct sockaddr_in6 address, remote;
#else
	struct sockaddr_in address, remote;
#endif /* LWIP_IPV6 */
	int size;

	/* set up address to connect to */
        memset(&address, 0, sizeof(address));
#if LWIP_IPV6==1
	if ((sock = lwip_socket(AF_INET6, SOCK_STREAM, 0)) < 0) {
		xil_printf("TCP server: Error creating Socket\r\n");
		return;
	}
	address.sin6_family = AF_INET6;
	address.sin6_port = htons(TCP_CONN_PORT);
	address.sin6_len = sizeof(address);
#else
	if ((sock = lwip_socket(AF_INET, SOCK_STREAM, 0)) < 0) {
		xil_printf("TCP server: Error creating Socket\r\n");
		return;
	}
	address.sin_family = AF_INET;
	address.sin_port = htons(TCP_CONN_PORT);
	address.sin_addr.s_addr = INADDR_ANY;
#endif /* LWIP_IPV6 */

	if (bind(sock, (struct sockaddr *)&address, sizeof (address)) < 0) {
		xil_printf("TCP server: Unable to bind to port %d\r\n",
				TCP_CONN_PORT);
		close(sock);
		return;
	}

	if (listen(sock, 1) < 0) {
		xil_printf("TCP server: tcp_listen failed\r\n");
		close(sock);
		return;
	}

	size = sizeof(remote);

	while (1) {
		if ((new_sd = accept(sock, (struct sockaddr *)&remote,
						(socklen_t *)&size)) > 0)
			sys_thread_new("TCP server thread",
					tcp_server_thread, (void*)&new_sd,
				TCP_SERVER_THREAD_STACKSIZE,
				DEFAULT_THREAD_PRIO);
	}
};
