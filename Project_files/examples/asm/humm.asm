;
; $Id: humm.asm,v 1.1.1.1 2002/01/15 00:52:39 mai Exp $
;
; Accessing DATA SAMPLE MEMORY

; ACCESSING SCRATCH MEMORY & RESULTS CHARACTER CONVERTER

START_SM  = 0x80            ; Start of the Data Sample Memory
END_SM    = 0xdf            ; 
Length_SM = (0xdf-0x80)     ; Length of the RAM being tested

; Writing into the 96 words of the Data Scratch Memory

        LDPK 1              ; Set Data Pointer to Page 1
LOOP:   ZAC                 ; Zero Accumulator
        LARP AR0            ; Set ARP to point to AR(0) 
        LARK AR0,START_SM   ; Set AR(0) to start address
        LARK AR1,Length_SM  ; Set AR(1) to the length
LOOP1:  SAR 0,*+,1          ; Store AR(0) in RAM
        BANZ LOOP1,*-,0     ; Decrement length, loop till all locations are done

; Accessing Port Registers

port1   =   0
port2   =   1
port3   =   2
port4   =   3
port5   =   4
port6   =   5
port7   =   6
port8   =   7

          LDPK 1            ;
          LARP AR0          ; Set ARP to point to AR(0) 
          LARK AR0, 0xAA    ;
          LARK AR1, 0xCC
          SAR AR0, *
          OUT *,port1,1     ; Send AR(0) to port1
          IN  *,port1,0     ; Read AA to AR(1)   
          OUT *,port2,1     ; Send AR(0) to port2
          IN  *,port2,0     ; Read AA to AR(1)
          OUT *,port3,1     ; Send AR(0) to port3
          IN  *,port3,0     ; Read AA to AR(1)
          OUT *,port4,1     ; Send AR(0) to port4
          IN  *,port4,0     ; Read AA to AR(1)
          OUT *,port5,1     ; Send AR(0) to port5
          IN  *,port5,0     ; Read AA to AR(1)
          OUT *,port6,1     ; Send AR(0) to port6
          IN  *,port6,0     ; Read AA to AR(1)
          OUT *,port7,1     ; Send AR(0) to port7
          IN  *,port7,0     ; Read AA to AR(1)
          OUT *,port8,1     ; Send AR(0) to port8
          IN  *,port8,0     ; Read AA to AR(1)

; Accessing Results Character Conversion Regusters

          LDPK 1            ;
          LARP AR0          ;
          LARK AR0, 0xe0    ;
          LARK AR1, 0x08    ;
          LACK 49           ; Load Accumulator with 49 (hex 31)           
LOOP2:    SACL *+,AR1       ;
          BANZ LOOP2,*-,0   ; Decrement length, loop till all locations are done
          B LOOP            ;
