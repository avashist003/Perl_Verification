;
;
; $Id: dtmf_tdsp.asm,v 1.1.1.1 2002/01/15 00:52:38 mai Exp $
;
; Author:  Mark A. Indovina
;          Rochester, NY, USA
;
; @(#) dtmf_tdsp.asm 5.2@(#)
; 6/6/96  11:25:30
;
;*********************************************************
;
; Module:	DTMF Receiver
; Target:	tdsp based, DTMF receiver chip
; Author:	Mark A. Indovina
;			Cadence Design Systems, Inc.
;			CSD-IC Technology Labratory
;
; Routines contained in the program will detect the dtmf tones which are
; used to signal dialed digit information between telephony equipment.
;
; the dtmf, dual tone band/multi-frequency, tones are eight in number:
; 697hz
; 770hz
; 852hz
; 941hz
; 1209hz
; 1336hz
; 1477hz
; 1633hz
;
; To detect the tones, a discrete fourier transform (DFT) will be
; used. The DFT will calculate the frequency response of
; the input signal. To minimize the calculation time, a straight
; DFT will not be calculated, in turn the program will use
; Goertzel's algorithm. the algorithm is an efficient method
; of writing the DFT difference equation. Through manipulation
; of the DFT difference equation, a reduction to a simple second
; order IIR filter can be obtained. This reduces the number of
; coefficients and complex multiplications to a minimum
; for routines that only return a portion of the actual
; frequency response.
;
; in signal flow form:
;
; x(n)>---+----->--------@--->-----+----->y(n)
;         |        d(n)|           |
;         |            |           |
;         ^            v           ^
;         |            |           |
;         | 2*cos(k,N) |  -W(k,N)  |
;         ^--<--*------0-@---*-->--^
;         |      d(n-1)|
;         |            |
;         ^            v
;         |            |
;         |     -1     |
;         ^-----*------0
;                d(n-2)
;
; where: 0 is a unit delay of one sample time
;	 + is a summing junction
;	 * is a multiply by a coef.
;	 @ is the algorithm break points
;
; the section to the left of the @ will need to be calculated
; for every iteration, the section to the right will only
; need to be computed at the nth iteration,
; when n=n, y(n)=y(n)=x(k), the normal dft output.
;
;*********************************************************
;
;
;*********************************************************
;
; program exection time:
;
; (note: actual dft, after block switch handshake)
;
; dtmf dft loop: ~3.17mS/frame
;            - frame time: 128 samples * 125uS/sample = 16.00mS
;
;*********************************************************
;
;
;*********************************************************
;
; history:
; 	28dec95........................created
; 	28jan96........................hack for tdsp
; 	26feb96........................hack for tdspasm
; 	28feb96........................add agc function
;
;*********************************************************
;
;
;*********************************************************
;
; memory map:
;
;              tdsp program rom: >0000 - >00ff	(program address space)
;          tdsp data sample ram: >0000 - >007f	(data address space)
;          tdsp scratch pad ram: >0080 - >00df	(data address space)
;  results character conversion: >00e0 - >00ef	(data address space)
;                system control: >0000 - >0007	(port address space)
;                     ->  select dma to generate address bit 7: 0x00
;                     -> select tdsp to generate address bit 7: 0x01
;                     ->  tdsp select lower data sample buffer: 0x02
;                     ->  tdsp select upper data sample buffer: 0x03
;
;*********************************************************
;
; notes:
;
; 	the bio pin will be used to monitor when the pcm ram is full
;
;*********************************************************
;
;
;*********************************************************
;
; --> equates begin here <--
;
;*********************************************************
; general equates
;
page0		=	0		; memory page 0
page1		=	1		; memory page 1
base_page0	=	0x000	; memory page 0
base_page1	=	0x080	; memory page 1
;
;
;*********************************************************
;
; from the flow graph:
;  d(n) = x(n) + 2*cos(2*pi*k/N)*d(n-1) - d(n-2)
;  y(n) = x(k) = x(n) + 2*cos(2*pi*k/N)*d(n-1) - d(n-2) - W(k,N)*d(n-1)
;   where: W(k,N) = cos(2*pi*k/N) + j*sin(2*pi*k/N)
;
pi			= 3.1415926355	; good old pi
;
N			= 128			; set length of transform to 128 samples
8KHz		= 8000			; sample rate
;
xform_len	= (N - 2)		; inner product transform length
;
ds_ptr		= 0				; base pointer of data sample memory
;
; for the purpose of this excercise, we'll force the Goertzel filters
;  on frequency - this will "smear" the spectrum, but, we'll get
;  the reponse we want
;
; the frequency bin index, k, is calculated as:
;
;       <center freq>
;   k = ------------- * <transform length, N>
;       <sample freq>
;
; desired center frequencies
;
697Hz	= 697			;
770Hz	= 770			;
852Hz	= 852			;
941Hz	= 941			;
1209Hz	= 1209			;
1336Hz	= 1336			;
1477Hz	= 1477			;
1633Hz	= 1633			;
;
; center frequencies k factors
;
k_697Hz		= ((697Hz/8KHz)*N)&0x7ff	;
k_770Hz		= ((770Hz/8KHz)*N)&0x7ff	;
k_852Hz		= ((852Hz/8KHz)*N)&0x7ff	;
k_941Hz		= ((941Hz/8KHz)*N)&0x7ff	;
k_1209Hz	= ((1209Hz/8KHz)*N)&0x7ff	;
k_1336Hz	= ((1336Hz/8KHz)*N)&0x7ff	;
k_1477Hz	= ((1477Hz/8KHz)*N)&0x7ff	;
k_1633Hz	= ((1633Hz/8KHz)*N)&0x7ff	;
;
; floating point real coefficients
;
fp_rc_697Hz	= cos((2*pi*k_697Hz)/N)	;
fp_rc_770Hz	= cos((2*pi*k_770Hz)/N)	;
fp_rc_852Hz	= cos((2*pi*k_852Hz)/N)	;
fp_rc_941Hz	= cos((2*pi*k_941Hz)/N)	;
fp_rc_1209Hz	= cos((2*pi*k_1209Hz)/N)	;
fp_rc_1336Hz	= cos((2*pi*k_1336Hz)/N)	;
fp_rc_1477Hz	= cos((2*pi*k_1477Hz)/N)	;
fp_rc_1633Hz	= cos((2*pi*k_1633Hz)/N)	;
;
; normalized real coefficients
;
rc_697Hz	= 0x7fff * fp_rc_697Hz			;
rc_770Hz	= 0x7fff * fp_rc_770Hz			;
rc_852Hz	= 0x7fff * fp_rc_852Hz			;
rc_941Hz	= 0x7fff * fp_rc_941Hz			;
rc_1209Hz	= 0x7fff * fp_rc_1209Hz			;
rc_1336Hz	= 0x7fff * fp_rc_1336Hz			;
rc_1477Hz	= 0x7fff * fp_rc_1477Hz			;
rc_1633Hz	= 0x7fff * fp_rc_1633Hz			;
;
; floating point imaginary coefficients
;
fp_ic_697Hz	= sin((2*pi*k_697Hz)/N)	;
fp_ic_770Hz	= sin((2*pi*k_770Hz)/N)	;
fp_ic_852Hz	= sin((2*pi*k_852Hz)/N)	;
fp_ic_941Hz	= sin((2*pi*k_941Hz)/N)	;
fp_ic_1209Hz	= sin((2*pi*k_1209Hz)/N)	;
fp_ic_1336Hz	= sin((2*pi*k_1336Hz)/N)	;
fp_ic_1477Hz	= sin((2*pi*k_1477Hz)/N)	;
fp_ic_1633Hz	= sin((2*pi*k_1633Hz)/N)	;
;
; normalized imaginary coefficients
;
ic_697Hz	= 0x7fff * fp_ic_697Hz			;
ic_770Hz	= 0x7fff * fp_ic_770Hz			;
ic_852Hz	= 0x7fff * fp_ic_852Hz			;
ic_941Hz	= 0x7fff * fp_ic_941Hz			;
ic_1209Hz	= 0x7fff * fp_ic_1209Hz			;
ic_1336Hz	= 0x7fff * fp_ic_1336Hz			;
ic_1477Hz	= 0x7fff * fp_ic_1477Hz			;
ic_1633Hz	= 0x7fff * fp_ic_1633Hz			;
;
; recalculated center frequencies
;
freq_697Hz	= k_697Hz * (8KHz/N)	;
freq_770Hz	= k_770Hz * (8KHz/N)	;
freq_852Hz	= k_852Hz * (8KHz/N)	;
freq_941Hz	= k_941Hz * (8KHz/N)	;
freq_1209Hz	= k_1209Hz * (8KHz/N)	;
freq_1336Hz	= k_1336Hz * (8KHz/N)	;
freq_1477Hz	= k_1477Hz * (8KHz/N)	;
freq_1633Hz	= k_1633Hz * (8KHz/N)	;
;
; freqency percent error calculations
;
error_697Hz	= ((697Hz - freq_697Hz)/697Hz) * 100	;
error_770Hz	= ((770Hz - freq_770Hz)/770Hz) * 100	;
error_852Hz	= ((852Hz - freq_852Hz)/852Hz) * 100	;
error_941Hz	= ((941Hz - freq_941Hz)/941Hz) * 100	;
error_1209Hz	= ((1209Hz - freq_1209Hz)/1209Hz) * 100	;
error_1336Hz	= ((1336Hz - freq_1336Hz)/1336Hz) * 100	;
error_1477Hz	= ((1477Hz - freq_1477Hz)/1477Hz) * 100	;
error_1633Hz	= ((1633Hz - freq_1633Hz)/1633Hz) * 100	;
;
;*********************************************************
;
; dma 0-7 are used to hold the real coefficients
recf1	=	0
recf2	=	1
recf3	=	2
recf4	=	3
recf5	=	4
recf6	=	5
recf7	=	6
recf8	=	7
;
; dma 8-15 are used to hold the imaginary coefficients
imcf1	=	8
imcf2	=	9
imcf3	=	10
imcf4	=	11
imcf5	=	12
imcf6	=	13
imcf7	=	14
imcf8	=	15
;
d_scale	=	16	; input, xk, scale factor
max_var	=	17	; maximum state variable value
agc_cnt	=	18	; agc count
one		=	19	;
zero	=	20	;
;
ptr		=	21	;
rcc_ptr	=	22	;
frm_ptr	=	23
len_ptr	=	24
agc_ptr	=	25
scale	=	26	; input, xk, scale factor
;
xk		=	30	; this is the input sample
real	=	31	; this is the temporary real part of yk
imag	=	32	; this is the temporary imaginary part of yk
;
; dma 40-55 are used as the delay element registers
dla1	=	40
dla2	=	41
dlb1	=	42
dlb2	=	43
dlc1	=	44
dlc2	=	45
dld1	=	46
dld2	=	47
dle1	=	48
dle2	=	49
dlf1	=	50
dlf2	=	51
dlg1	=	52
dlg2	=	53
dlh1	=	54
dlh2	=	55
dl_len	=	(dlh2 - dla1)
;
; dma 60-67 are used to hold the freq bin power magnitude
pow1	=	60
pow2	=	61
pow3	=	62
pow4	=	63
pow5	=	64
pow6	=	65
pow7	=	66
pow8	=	67
;
; hold the current and last bio pointer for sync with ram
bio1	=	70
bio2	=	71
;
; dma pointers to the results character converter
rcc_697Hz	= (0x00e0 & 0x07f)			;
rcc_770Hz	= (0x00e1 & 0x07f)			;
rcc_852Hz	= (0x00e2 & 0x07f)			;
rcc_941Hz	= (0x00e3 & 0x07f)			;
rcc_1209Hz	= (0x00e4 & 0x07f)			;
rcc_1336Hz	= (0x00e5 & 0x07f)			;
rcc_1477Hz	= (0x00e6 & 0x07f)			;
rcc_1633Hz	= (0x00e7 & 0x07f)			;
rcc_kick	= (0x00e8 & 0x07f)			;
rcc_len		= (rcc_kick - rcc_697Hz)	;
;
sel_dma			= 0x00	; pa0
sel_tdsp		= 0x01	; pa1
sel_low_buf		= 0x02	; pa2
sel_hi_buf		= 0x03	; pa3
;
;*********************************************************
;
start:	b	dtmfc	; branch to program start
;
; ********************************************************
;
; ** this table contains the
;    coefficients used by the program
;
; -- fractional 16 bit numbers are represented in q15 format,
; the msb is the sign bit, followed by 15 fractional bits ->
; (sign bit) . (15 fractional bits)
;
; -- the tdsp accumulator will utilize fractional 32 bit numbers
; in q30 format, the two msb's are equivalent sign bits, followed
; by 30 fractional bits ->
; (2 sign bits) . (30 fractional bits)
;
; real/imaginary and more scale coefficients
; for the dft routines.
;
start_of_coef:
dtmf_r_coef:	.data	rc_697Hz		; dtmf real coef. 1
				.data	rc_770Hz		; 
				.data	rc_852Hz		; 
				.data	rc_941Hz		; 
				.data	rc_1209Hz		; 
				.data	rc_1336Hz		; 
				.data	rc_1477Hz		; 
end_r_coef:		.data	rc_1633Hz		; dtmf real coef. 8
dtmf_i_coef:	.data	ic_697Hz		; dtmf imag. coef. 1
				.data	ic_770Hz		; 
				.data	ic_852Hz		; 
				.data	ic_941Hz		; 
				.data	ic_1209Hz		; 
				.data	ic_1336Hz		; 
				.data	ic_1477Hz		; 
end_i_coef:		.data	ic_1633Hz		; dtmf imag. coef. 8
;
; the following coefficient will scale the maximum output
;  of the dft to .95. the accum. equivalent of +3dbm will
;  therefore be .95 (>799a). a value of .4761 (>3cf2) in 
;  the accum. is  equivalent to 0dbm.
;
; **** scale coefficient calculation:
;
;           sqrt(.95) * 2
;      x = ---------------  * where N is the number of samples
;          (.24508667) * N    taken. (.24508667) is the maximum
;                             value of the linearized 16 bit pcm.
;
max_pcm_mag		=	0x0f	;
max_pcm_seg		=	0x07	;
max_pcm			=	(((max_pcm_mag << 1) + 33) << max_pcm_seg) - 33 ;
fp_max_pcm		=	max_pcm/0x7fff ;
fp_scale_coef	=	((sqrt(.95)*2)/((.24508667)*N))		; dtmf power scale factor
;scale_coef		=	(0x7fff * fp_scale_coef)			; normalized dtmf power scale factor
scale_coef		=	(0x7fff * .9)						; normalized dtmf power scale factor
max_state_var	=	(.95 * 0x7fff) * .4					; maximum state variable value
;
state_loop_count	=	12 ;
;
dtmf_scale_coef:	.data	scale_coef					; dtmf power scale factor
;
					.data	max_state_var				;
					.data	(state_loop_count-1)		;
					.data	1							;
end_of_coef:		.data	0							;
;
coef_len	= end_of_coef - start_of_coef		; length of coefficient table
;
; ********************************************************
;
; Start of program
; 	- this is the dtmf configuration loop
;
dtmfc:	ldpk	page1	; point to memory page 1
		sovm			; set overflow mode
		lack	1
		sacl	one
;
; ********************************************************
;
;
;---------------------------------------------------------
;
; load the coefficients
;
		larp	ar0
		lark	ar0,(recf1+base_page1)
		lack	start_of_coef
		lark	ar1,coef_len
dtrlp:	tblr	*+,1
		add	one
		banz	dtrlp,*-,ar0
;
; preload the bio flags for synchronization with the dsram
;
		lack	1
		sacl	bio1
		sacl	bio2
;
; **************************
; this is the discrect fourier
; transform calculation algorithm,
; it is written in straight line
; code to minimize time wasted in looping.
; the input will be xk, the data sample,
; and the output will be the power
; of the frequency bins.
;
dcalc:
;
; need to have some syncronization with the ram
; the following will sync. on the bio pin
;
		zals	bio1
		bnz		wait0
;
wait1:	lack	1
		sacl	bio1
dwait1:	bioz	dwait1	; wait for bio to be high before starting
		b		dfst
;
wait0:	zac
		sacl	bio1
dwait0:	bioz	dfst	; wait for bio to be low before starting
		b		dwait0
;
; **** dtmf dft starts here
;
dfst:
;
; get scale factor
;
		lac		d_scale
		sacl	scale
;
; zero delay elements
;
ddz:	zac
		lark	ar1,dl_len	; using all 16 delay elements
		lark	ar0,(dla1+base_page1)	; start with dla1
ddzl:	sacl	*+,ar1
		banz	ddzl,*-,ar0
;
; load ar0 with agc count
		lar		ar0,agc_cnt
		sar		ar0,agc_ptr
;
; load ar0 with data sample memory pointer
		lark	ar0,(ds_ptr+base_page0)	; using all 16 delay elements
;
; load ar1 with transform length
		lark	ar1,xform_len	; start with dla1
;
; dft loop, index here goes from 0-(N-2)
;
ddftl:	lac		*+,0,ar1	; read sample
		sar		ar0,frm_ptr
		sar		ar1,len_ptr
		sacl	xk			; move to xk
;
; this calculates the inner loop for 697hz
; tdsp difference equation:
; dla0 = xk*scale + 2*recf1*dla1 - dla2
;
; actual difference equation:
; d(n) = x(n) + 2*cos(2*pi*k/N)*d(n-1) - d(n-2)
;
	lt	xk		; Load multiply temporary operand with data sample, x
	mpy	scale		; Multiply
				;   xk * scale -> p
	ltp	dla1		; Load multiply temporary operand with dla1
				; Move last multiply product to accumulator
				;   xk * scale -> ACC
	mpy	recf1		; Multiply
				;   dla1 * recf1
	apac			; Add last multiply product to accumulator
				;   ACC + recf1*dla1 -> ACC
	apac			; Add last multiply product to accumulator
				;   ACC + recf1*dla1 -> ACC
	sub	dla2,15		; Subtract
				;   ACC - (dla2 << 15 ) -> ACC
	dmov	dla1		; dla1 is copied to dla2
	sach	dla1,1		; store (ACCH << 1) -> dla1
;
; for 770hz
;
	lt	xk
	mpy	scale
	ltp	dlb1
	mpy	recf2
	apac
	apac
	sub	dlb2,15
	dmov	dlb1
	sach	dlb1,1
;
; for 852hz
;
	lt	xk
	mpy	scale
	ltp	dlc1
	mpy	recf3
	apac
	apac
	sub	dlc2,15
	dmov	dlc1
	sach	dlc1,1
;
; for 941hz
;
	lt	xk
	mpy	scale
	ltp	dld1
	mpy	recf4
	apac
	apac
	sub	dld2,15
	dmov	dld1
	sach	dld1,1
;
; for 1209hz
;
	lt	xk
	mpy	scale
	ltp	dle1
	mpy	recf5
	apac
	apac
	sub	dle2,15
	dmov	dle1
	sach	dle1,1
;
; for 1336hz
;
	lt	xk
	mpy	scale
	ltp	dlf1
	mpy	recf6
	apac
	apac
	sub	dlf2,15
	dmov	dlf1
	sach	dlf1,1
;
; for 1477hz
;
	lt	xk
	mpy	scale
	ltp	dlg1
	mpy	recf7
	apac
	apac
	sub	dlg2,15
	dmov	dlg1
	sach	dlg1,1
;
; for 1633hz
;
	lt	xk
	mpy	scale
	ltp	dlh1
	mpy	recf8
	apac
	apac
	sub	dlh2,15
	dmov	dlh1
	sach	dlh1,1
;
; now check and see if we need to perform and agc update
;
	lar		ar1,agc_ptr
	banz	ddft_ilr
;
; agc count has expired, now check and see if we need to scale
; the state variables
;
ddtf_agc_ck:	lark	ar0,dl_len	; using all 16 delay elements
				lark	ar1,(dla1+base_page1)	; start with dla1
ddtf_agc_ckl:	lac		*+,0,ar0
				abs
				sub		max_var
				bgez	ddtf_agc_sv				; if less than zero, variable is ok
				banz	ddtf_agc_ckl,*-,ar1
;
				b		ddtf_agc_exit			; all ok, jump and exit
;
; scale shift variables by 1/2
;
ddtf_agc_sv:	larp	ar1
				lark	ar0,dl_len	; using all 16 delay elements
				lark	ar1,(dla1+base_page1)	; start with dla1
ddtf_agc_svl:	lac		*,15
				sach	*+,0,ar0
				banz	ddtf_agc_svl,*-,ar1
;
; scale scale factor by 1/2
;
				lac		scale,15
				sach	scale
;
ddtf_agc_exit:	lar		ar1,agc_cnt
;
; this pass done, increment internal page address and return,
; do this until ar1 is zero
;
ddft_ilr:	sar		ar1,agc_ptr
			lar		ar0,frm_ptr
			lar		ar1,len_ptr
ddftil:		banz	ddftl,*-,ar0
;
; the dft index now equals (N-1), yk will now equal
; the frequency magnitude after calculation.
; calculate the last point, then calculate 
; the frequency bin power:
;
ddft_ol:	lac		*+,0,ar0	; read sample
			sacl	xk			; move to xk
;
; calculate the inner loop, outer loop and then the power,
; or magnitude squared for 697hz
; tdsp difference equation:
; real = xk*scale + recf1*dla1 - dla2
; imag = imcf1*dla1
; pow1 = real*real + imag*imag
;
; actual difference equation:
; y(n) = x(k) = x(n) + 2*cos(2*pi*k/N)*d(n-1) - d(n-2) - W(k,N)*d(n-1)
; where: W(k,N) = cos(2*pi*k/N) + j*sin(2*pi*k/N)
;	 y(n) is a complex number
;	 y(n) = x(k), which is the frequency domain output of a dft.
;
	lt	xk		; Load multiply temporary operand with data sample, x
	mpy	scale		; Multiply
				;   xk * scale -> p
	ltp	dla1		; Load multiply temporary operand with dla1
				; Move last multiply product to accumulator
				;   xk * scale -> ACC
	mpy	recf1		; Multiply
				;   dla1 * recf1
	apac			; Add last multiply product to accumulator
				;   ACC + recf1*dla1 -> ACC
	sub	dla2,15		; Subtract
				;   ACC - (dla2 << 15 ) -> ACC
	sach	real,1		; store (ACCH << 1) -> real
	mpy	imcf1		; Multiply
				;   dla1 * imcf1 -> p
	ltp	real		; Load multiply temporary operand with real
				; Move last multiply product to accumulator
				;   dla1 * imcf1 -> ACC
	sach	imag,1		; store (ACCH << 1) -> imag
	mpy	real		; Multiply
				;   real * real -> p
	ltp	imag		; Load multiply temporary operand with imag
				; Move last multiply product to accumulator
				;   real * real -> ACC
	mpy	imag		; Multiply
				;   imag * imag -> p
	apac			; Add last multiply product to accumulator
				;   ACC + imag * imag -> ACC
	sach	pow1,1		; store (ACCH << 1) -> pow1
;
; for 770hz
;
	lt	xk
	mpy	scale
	ltp	dlb1
	mpy	recf2
	apac
	sub	dlb2,15
	sach	real,1
	mpy	imcf2
	ltp	real
	sach	imag,1
	mpy	real
	ltp	imag
	mpy	imag
	apac
	sach	pow2,1
;
; for 852hz
;
	lt	xk
	mpy	scale
	ltp	dlc1
	mpy	recf3
	apac
	sub	dlc2,15
	sach	real,1
	mpy	imcf3
	ltp	real
	sach	imag,1
	mpy	real
	ltp	imag
	mpy	imag
	apac
	sach	pow3,1
;
; for 941hz
;
	lt	xk
	mpy	scale
	ltp	dld1
	mpy	recf4
	apac
	sub	dld2,15
	sach	real,1
	mpy	imcf4
	ltp	real
	sach	imag,1
	mpy	real
	ltp	imag
	mpy	imag
	apac
	sach	pow4,1
;
; for 1209hz
;
	lt	xk
	mpy	scale
	ltp	dle1
	mpy	recf5
	apac
	sub	dle2,15
	sach	real,1
	mpy	imcf5
	ltp	real
	sach	imag,1
	mpy	real
	ltp	imag
	mpy	imag
	apac
	sach	pow5,1
;
; for 1336hz
;
	lt	xk
	mpy	scale
	ltp	dlf1
	mpy	recf6
	apac
	sub	dlf2,15
	sach	real,1
	mpy	imcf6
	ltp	real
	sach	imag,1
	mpy	real
	ltp	imag
	mpy	imag
	apac
	sach	pow6,1
;
; for 1477hz
;
	lt	xk
	mpy	scale
	ltp	dlg1
	mpy	recf7
	apac
	sub	dlg2,15
	sach	real,1
	mpy	imcf7
	ltp	real
	sach	imag,1
	mpy	real
	ltp	imag
	mpy	imag
	apac
	sach	pow7,1
;
; for 1633hz
;
	lt	xk
	mpy	scale
	ltp	dlh1
	mpy	recf8
	apac
	sub	dlh2,15
	sach	real,1
	mpy	imcf8
	ltp	real
	sach	imag,1
	mpy	real
	ltp	imag
	mpy	imag
	apac
	sach	pow8,1
;
; write out calculated spectrum to "results character conversion block"
;
d_out_sp:	lark	ar1,rcc_len		; length of rcc register block
			lark	ar0,(rcc_697Hz+base_page1)	; starting address
			sar		ar0,rcc_ptr
			lark	ar0,(pow1+base_page1)
			sar		ar0,ptr
d_out_sp_l:	lar		ar0,ptr
			zals	*+
			sar		ar0,ptr
			lar     ar0,rcc_ptr
			sacl	*+,ar1
			sar		ar0,rcc_ptr
			banz	d_out_sp_l,*-,ar0
;
; return to calculation routine
;
	b	dcalc
;
end:	; end of program
length = (end - start)	;	length of program
;
;---------------------------------------------------------
;
