#include <xc.h>
#define _XTAL_FREQ 4000000

void main(void){
    char i,j;
    unsigned char eeadcnt;
    unsigned char pbufa,pbufb;
    TRISA=0x00;
    TRISB=0x00;
    PORTA=0xff;
    PORTB=0x00;

    while(1){
        eeadcnt=0;
        for(i=0;i<8;i++){
            for(j=0;j<16;j++){
                //EEPROM TO PORT BUF
                pbufa=eeprom_read(eeadcnt);
                eeadcnt++;
                pbufb=eeprom_read(eeadcnt);
                eeadcnt++;

                //CONVERT DATA PORT BUF
                pbufa=(pbufa & 0x3f) | ((pbufa << 1) & 0xc0);

                //OUTPUT DATA
                PORTA=pbufa;
                PORTB=~pbufb;
                __delay_ms(1);
                PORTA=0xff;
                PORTB=0x00;
                __delay_ms(2);
            }
            __delay_ms(1);
        }
    }
}
