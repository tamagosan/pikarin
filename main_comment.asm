;LEDぴかりん棒
	LIST P=PIC16F648A	;PIC16F648Aを使用すると宣言
	INCLUDE "P16F648A.INC"	;設定ファイルP16F648A.INCを読み込む
	__CONFIG	H'2110'	;コンフィギュレーション
	__IDLOCS	H'1000'	;
	
	CBLOCK	H'20'		;ユーザー定義ファイルレジスタを0x20番地から指定
	CHARCNT			;Charakuta Countの略だと思われる
	LINECNT			;Line Countの略だと思われる
	EEADCNT			;EEPROM Address Countの略だと思われる
	
	PBUFA			;
	PBUFB			;
	
	TIMCNT1			;Timer Count1
	TIMCNT2			;Timer Count2
	
	WORK			;計算補助
	ENDC			;ユーザー定義ファイルレジスタここまで
	
	ORG	0		;リセットベクタを指定
	ORG	4		;割込みベクタを指定
INIT				;ラベルINIT
	CLRF	PORTA		;PORTAをクリア
	CLRF	PORTB		;PORTBをクリア
	
	MOVLW	H'07'		;0x07をワーキングレジスタに格納
	MOVWF	CMCON		;ワーキングレジスタ(0x07)をCMCON(コンパレータ)に設定
	
	BSF	STATUS,RP0	;バンク1に切替
	
	MOVLW	h'00'		;0x00をワーキングレジスタに格納
	MOVWF	TRISA		;ワーキングレジスタ(0x00)をTRISA(PORTA入力ピン)に設定
	MOVLW	h'00'		;0x00をワーキングレジスタに格納
	MOVWF	TRISB		;ワーキングレジスタ(0x00)をTRISB(PORTB入力ピン)に設定
	
	BCF	STATUS,RP0	;バンク0に切替
	
	MOVLW	H'FF'		;0xFFをワーキングレジスタに格納
	MOVWF	PORTA		;ワーキングレジスタ(0xFF)をPORTAに出力
	CLRF	PORTB		;PORTBをクリア
START				;ラベルSTART
	CLRF	EEADCNT		;ファイルレジスタEEADCNTをクリア
	MOVLW	D'8'		;十進数としての8をワーキングレジスタに格納
	MOVWF	CHARCNT		;ワーキングレジスタ(0x08)をファイルレジスタCHARCNTに格納
CHARLP				;ラベルCHARLP
	MOVLW	D'16'		;十進数としての16をワーキングレジスタに格納
	MOVWF	LINECNT		;ワーキングレジスタ(0x10)をファイルレジスタLINECNTに格納
;********EEPROM TO PORT BUF*******
LINELP				;ラベルLINELP
	MOVF	EEADCNT,W	;ファイルレジスタEEADCNTをワーキングレジスタに格納
	BSF	STATUS,RP0	;バンク1に切替
	MOVWF	EEADR		;ワーキングレジスタ(EEADCNT)をEEPROMの読取アドレスとして指定
	BSF	EECON1,RD	;EEPROMデータ読み取りモードに切替
	MOVF	EEDATA,W	;EEPROMデータをワーキングレジスタに格納
	BCF	STATUS,RP0	;バンク0に切替
	MOVWF	PBUFA		;ワーキングレジスタ(EEPROMデータ)をファイルレジスタPBUFAに格納
	INCF	EEADCNT,F	;ファイルレジスタEEADCNTをインクリメント
	
	MOVF	EEADCNT,W	;ファイルレジスタEEADCNTをワーキングレジスタに格納
	BSF	STATUS,RP0	;バンク1に切替
	MOVWF	EEADR		;ワーキングレジスタ(EEADCNT)をEEPROMの読取アドレスとして指定
	BSF	EECON1,RD	;EEPROMデータ読み取りモードに切替
	MOVF	EEDATA,W	;EEPROMデータをワーキングレジスタに格納
	BCF	STATUS,RP0	;バンク0に切替
	MOVWF	PBUFB		;ワーキングレジスタ(EEPROMデータ)をファイルレジスタPBUFBに格納
	INCF	EEADCNT,F	;ファイルレジスタEEADCNTをインクリメント
;*******CONVERT DATA PORT BUF********
	MOVF	PBUFA,W		;ファイルレジスタPBUFAをワーキングレジスタに格納
	MOVWF	WORK		;ワーキングレジスタ(PBUFA)をファイルレジスタ(WORK)に格納
	RLF	WORK,W		;ファイルレジスタWORKを左にローテート(キャリフラグを通す)し、ワーキングレジスタに格納
	ANDLW	H'C0'		;ワーキングレジスタ(WORK<<1)と0xC0(0b11000000)の論理積をワーキングレジスタに格納
	MOVWF	WORK		;ワーキングレジスタの内容((WORK << 1) & 0xC0)をファイルレジスタWORKに格納
	MOVF	PBUFA,W		;ファイルレジスタPBUFAをワーキングレジスタに格納
	ANDLW	H'3F'		;ワーキングレジスタ(PBUFA)と0x3F(0b00111111)の論理積をワーキングレジスタに格納
	IORWF	WORK,W		;ワーキングレジスタ(PBUFA & 0x3F)とファイルレジスタWORKの論理和をワーキングレジスタに格納
	MOVWF	PBUFA		;ワーキングレジスタ((PBUFA & 0x3F) | ((WORK << 1) & 0xC0)をファイルレジスタPBUFAに格納
;**************OUTPUT DATA************
	MOVF	PBUFA,W		;ファイルレジスタPBUFAをワーキングレジスタに格納
	MOVWF	PORTA		;ワーキングレジスタ(PBUFA)をPORTAに出力
	COMF	PBUFB,W		;ファイルレジスタPBUFBを論理反転しワーキングレジスタに格納
	MOVWF	PORTB		;ワーキングレジスタ(~PBUFB)をPORTBに出力
	CALL	WAITONE		;WAITONEルーチンをコール
	MOVLW	H'FF'		;0xFFをワーキングレジスタに格納
	MOVWF	PORTA		;ワーキングレジスタ(0xFF)をPORTAに出力
	CLRF	PORTB		;PORTBをクリア
	CALL	WAITONE		;WAITONEルーチンをコール
	CALL	WAITONE		;WAITONEルーチンをコール
	DECFSZ	LINECNT,F	;ファールレジスタLINECNTをデクリメント
	GOTO	LINELP		;ファイルレジスタLINECNTが0でなければラベルLINELPへ
	CALL	WAITONE		;WAITONEルーチンをコール
	DECFSZ	CHARCNT,F	;ファイルレジスタCHARCNTをデクリメント
	GOTO	CHARLP		;ファイルレジスタCHARCNTが0でなければラベルCHARLPへ
	GOTO	START		;ラベルSTARTへ
;SUB ROUTINES			;タイマルーチン
WAITONE				;ラベルWAITONE
	MOVLW	D'10'		;十進数としての10をワーキングレジスタに格納
	MOVWF	TIMCNT2		;ワーキングレジスタ(0x0a)をファールレジスタTIMCNT2に格納
WAITLP2				;ラベルWAITLP2
	MOVLW	D'30'		;十進数としての30をワーキングレジスタに格納
	MOVWF	TIMCNT1		;ワーキングレジスタ(0x1f)をファイルレジスタTIMCNT1に格納
WAITLP1				;ラベルWAITLP1
	DECFSZ	TIMCNT1,F	;ファイルレジスタTIMCNT1をデクリメント
	GOTO	WAITLP1		;ファイルレジスタTIMCNT1が0でなければラベルWAITLP1へ
	
	DECFSZ	TIMCNT2,F	;ファイルレジスタTIMCNT2をデクリメント
	GOTO	WAITLP2		;ファイルレジスタTIMCNT2が0でなければラベルWAITLP2へ
	RETURN			;タイマルーチンここまで
;=========================================================
;	データEE-PROM書き込みデータ　font　print　@kahja　によってデータ格納

;	ORG	0X2100
;	DE	0X11
;=========================================================
	END			;プログラムの終了をアセンブラに指示する
