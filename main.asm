    PROCESSOR 16F887
    #include <p16f887.inc>


__CONFIG _CONFIG1, _INTRC_OSC_NOCLKOUT & _WDT_OFF & _LVP_OFF & _MCLRE_ON 
__CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
CBLOCK 0x70
    ADC_DATA	;0x70 addr
ENDC
;RESET VECTOR
    ORG     0x00
    GOTO    MAIN_INIT
;INTERRUPT VECTOR
    ORG	    0x04
   
;MAIN CODE
      org 0x60      
MAIN_INIT:
    BANKSEL OSCCON
    MOVLW b'01100111'
    MOVWF OSCCON
    
    BANKSEL ANSEL   ;BANK3
    CLRF ANSEL
    CLRF ANSELH
    
    ;TIMER 2 SETUP
    BANKSEL TRISC   ;BANK1
    BCF TRISC,2	    ;set RC2 as output
    MOVLW h'ff'
    MOVWF PR2
    
    BANKSEL CCP1CON ;BANK0
    MOVLW b'00001100'	;PWM MODE, SINGLE OUTPUT
    MOVWF CCP1CON
    BSF T2CON,2	    ;TURN TMR2 ON
    ;TIMER2 END
    
    ;ADC setup
    BANKSEL TRISA
    BSF TRISA,0	    ;SET RA0 AS INPUT
    BANKSEL ANSELH
    BSF ANSEL,0
    BANKSEL ADCON1
    BCF ADCON1,7    ;we want left justified
    BCF ADCON1,5    ;INTERNAL VSS
    BCF ADCON1,4    ;INTERNAL VCC
    BANKSEL ADCON0
    MOVLW b'01000001'
    MOVWF ADCON0
    CALL DELAY_10US
    ;ADC END
    
    ;EUSART setup
    BANKSEL TRISC   ;BANK1
    BCF TRISC,6
    BCF TXSTA,6	    ;8bit transmission
    BCF TXSTA,4	    ;Asynchronous mode
    BSF TXSTA,2	    ;HIGH SPEED
    
    BANKSEL RCSTA   ;BANK0
    BSF RCSTA,7	    ;configures RX/DT and TX/CK pins as serial port pins
    BANKSEL SPBRG   ;BANK1
    MOVLW d'25'	    ;depending on the config of the EUSART u can find the values in the datasheet
    MOVWF SPBRG
    
    BANKSEL BAUDCTL ;BANK3
    BCF BAUDCTL,3   ;8-bit Baud Rate Generator is used, now the baudrate is 9615
    
    BANKSEL TXSTA   ;BANK1
    BSF TXSTA,5	    ;transmitter enabled
    ;EUSART END
    
    GOTO MAIN_LOOP
    
MAIN_LOOP:
    BANKSEL ADCON0
    BSF ADCON0,1
    CALL AN0_WAIT
    CALL EUSART_WAIT
    
    GOTO MAIN_LOOP
    
DELAY_10US:;SIMPLE 10US DELAY
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    NOP
    RETURN
    
AN0_WAIT:
    BANKSEL ADCON0   ;BANK0
    BTFSC ADCON0,1
    GOTO AN0_WAIT
    MOVF ADRESH,W
    MOVWF ADC_DATA
    MOVWF CCPR1L
    RETURN
    
EUSART_WAIT:
    BANKSEL PIR1
    BTFSS PIR1,4
    GOTO EUSART_WAIT
    BANKSEL TXREG
    MOVF ADC_DATA,W
    MOVWF TXREG
    
    
    RETURN
END