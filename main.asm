    PROCESSOR 16F887
    #include <p16f887.inc>


 __CONFIG _CONFIG1, _INTRC_OSC_NOCLKOUT & _WDT_OFF & _LVP_OFF & _MCLRE_ON
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
CBLOCK 0x70
    W_TEMP	;0x70 addr
    S_TEMP	;0x71 addr
    COUNTvar	;0x72 addr
 ENDC
;RESET VECTOR
    ORG     0x00
    GOTO    MAIN_INIT
;INTERRUPT VECTOR
    ORG	    0x04
    ;SWAPPING THE STATUS AND WROKING REGISTERS
    MOVWF W_TEMP
    SWAPF STATUS,W
    MOVWF S_TEMP
    ;DONE WITH SWAP
    
    BCF INTCON,2    ;CLR OVF FLAG MANUALLY
    INCF COUNTvar,F
    MOVF COUNTvar,W
   
    CALL LED_PATTERN
    
    MOVWF PORTD
    
    GOTO ISR_EXIT
    
LED_PATTERN:
    ANDLW 0x7	    ;so we will and the data in W reg with number 7 so the led would be between 0-7
    ADDWF PCL,F	    ;then we will add PCL AND Wreg data so depending on the data in Wreg the PCL will jump to one of the patterns
    RETLW b'00000001'	;if W is 0
    RETLW b'00000010'	;if W is 1
    RETLW b'00000100'	;if W is 2
    RETLW b'00001000'	;if W is 3
    RETLW b'00010000'	;if W is 4
    RETLW b'00100000'	;if W is 5
    RETLW b'01000000'	;if W is 6
    RETLW b'10000000'	;if W is 7
    
    
    
ISR_EXIT:
    SWAPF S_TEMP,W
    MOVWF STATUS
    SWAPF W_TEMP,F
    SWAPF W_TEMP,W
    RETFIE
   
;MAIN CODE
      org 0x50      
MAIN_INIT:
    BANKSEL OSCCON
    MOVLW b'01100111'
    MOVWF OSCCON
    
    BANKSEL ANSEL   ;BANK3
    CLRF ANSEL
    CLRF ANSELH
    
    BANKSEL TRISD   ;BANK1
    CLRF TRISD
    
    ;timer0 setup
    BCF OPTION_REG,5
    BCF OPTION_REG,3
    BSF OPTION_REG,0
    BSF OPTION_REG,1
    BSF OPTION_REG,2	;256 PCS
    
    BSF INTCON,7    ;ENABLE GIE
    BSF INTCON,5    ;OVF IE ENABLE FOR TMR0
    
    BANKSEL PORTD
    CLRF TMR0
    CLRF COUNTvar   ;we will use this address to save the OVF
    CLRF PORTD
MAIN_LOOP:
    
    GOTO    MAIN_LOOP
END