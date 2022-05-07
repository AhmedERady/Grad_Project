#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <error.h>
#include <stdint.h>
#include <sys/mman.h>

// Register Physical Addresses
#define HPS_TO_FPGA_LW_BASE 0xFF200000
#define HPS_TO_FPGA_LW_SPAN 0x0020000
#define MMUL_MASTER_0_BASE  0x0
#define LED_PIO_BASE        0x3000

// Write Offsets
#define i_wr 0
#define j_wr 1
#define k_wr 2
#define n_wr 3
#define s_wr 4

// Read Offsets
#define i_rd 5
#define j_rd 6
#define k_rd 7
#define n_rd 8
#define s_rd 9

void SM_write(unsigned short *base, int offset, unsigned short data);
void SM_write(unsigned short *base, int offset, unsigned short data){
    *(base + offset) = data;
}

unsigned short SM_uread(unsigned short *base, int offset);
unsigned short SM_uread(unsigned short *base, int offset){
    return *(base + offset);
}

signed short SM_sread(unsigned short *base, int offset);
signed short SM_sread(unsigned short *base, int offset){
    return *(base + offset);
}

int open_driver(void);
int open_driver(void){
    int fd = 0;
    if((fd = open("/dev/mem", O_RDWR | O_SYNC)) < 0) {
        perror("devmem open");
        exit(EXIT_FAILURE);
    }
    return fd;
}

void* LW_map(int fd);
void* LW_map(int fd){
    void* lw_bus_map = 0;
    lw_bus_map = (unsigned int*)mmap(NULL, HPS_TO_FPGA_LW_SPAN, PROT_READ|PROT_WRITE, MAP_SHARED, fd, HPS_TO_FPGA_LW_BASE); 
    if(lw_bus_map == MAP_FAILED) {
        perror("devmem mmap");
        close(fd);
        exit(EXIT_FAILURE);
    }

    return lw_bus_map;
}

void clean_up(void* lw_bus_map, int fd);
void clean_up(void* lw_bus_map, int fd){
    if((munmap(lw_bus_map, HPS_TO_FPGA_LW_SPAN)) < 0) {
        perror("devmem munmap");
        close(fd);
        exit(EXIT_FAILURE);
    }
    close(fd);
}

unsigned short* MMul_reference(void* lw_bus_map);
unsigned short* MMul_reference(void* lw_bus_map){
    return (unsigned short*)(lw_bus_map + MMUL_MASTER_0_BASE);
}


/*int main(void){
	void* lw_bus_map = 0;
    unsigned short* MMul_master = 0;
    unsigned short row = 0;
    unsigned short col = 0;
    unsigned short num = 0;
    int fd = 0;

    fd = open_driver();

    lw_bus_map = LW_map(fd);

    MMul_master = MMul_reference(lw_bus_map);

    // Program

    // Load ker_mat
    row = 55;
    col = 0;
    num = 5;

    SM_write(MMul_master, s_wr, 0x11);
    SM_write(MMul_master, i_wr, row);
    SM_write(MMul_master, k_wr, col);
    SM_write(MMul_master, n_wr, num);

    num = SM_read(MMul_master, i_rd);
    printf("%hu\n", num);
    
    // Load inp_mat
    row = 0;
    col = 0;
    num = 2;

    SM_write(MMul_master, s_wr, 0x21);
    SM_write(MMul_master, k_wr, row);
    SM_write(MMul_master, j_wr, col);
    SM_write(MMul_master, n_wr, num);

    // Start mult
    row = 1;
    col = 1;
    num = 1;

    SM_write(MMul_master, i_wr, row);
    SM_write(MMul_master, j_wr, col);
    SM_write(MMul_master, k_wr, num);
    SM_write(MMul_master, s_wr, 0x06);

    // Sleep for 1 clock cycle?
    SM_write(MMul_master, s_wr, 0x00);

    // Wait for mult fin
    while(SM_read(MMul_master, s_rd) != 0x08)
        usleep(1000*500);

    // Unload out_mat
    row = 1;
    col = 1;
    SM_write(MMul_master, s_wr, 0x48);
    SM_write(MMul_master, i_wr, row);
    SM_write(MMul_master, j_wr, col);
    num = SM_read(MMul_master, n_rd);
    printf("%hu\n", num);

    // Reset
    SM_write(MMul_master, s_wr, 0x0A);

    clean_up(lw_bus_map, fd);
	return(0);
}
*/