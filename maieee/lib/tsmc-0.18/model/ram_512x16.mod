/*
 *      CONFIDENTIAL AND PROPRIETARY SOFTWARE/DATA OF ARTISAN COMPONENTS, INC.
 *      
 *      Copyright (c) 2002 Artisan Components, Inc.  All Rights Reserved.
 *      
 *      Use of this Software/Data is subject to the terms and conditions of
 *      the applicable license agreement between Artisan Components, Inc. and
 *      Taiwan Semiconductor Manufacturing Ltd..  In addition, this Software/Data
 *      is protected by copyright law and international treaties.
 *      
 *      The copyright notice(s) in this Software/Data does not indicate actual
 *      or intended publication of this Software/Data.
 *
 *      Synopsys model for Synchronous Single-Port Ram
 *
 *      Library Name:   aci
 *      Instance Name:  ram_512x16
 *      Words:          512
 *      Word Width:     16
 *      Mux:            4
 *      Pipeline:       No
 *
 *      Creation Date:  2002-01-13 20:11:32Z
 *      Version:        2000Q3V1
 *
 *      Verified With: Synopsys Primetime
 *
 *      Modeling Assumptions: This library contains a black box description
 *          for a memory element.  At the library level, a
 *          default_max_transition constraint is set to the maximum
 *          characterized input slew.  Each output has a max_capacitance
 *          constraint set to the highest characterized output load.
 *          Different modes are defined in order to disable false path
 *          during the specific mode activation when doing static timing analysis. 
 *
 *
 *      Modeling Limitations: This stamp does not include power information.
 *          Due to limitations of the stamp modeling, some data reduction was
 *          necessary.  When reducing data, minimum values were chosen for the
 *          fast case corner and maximum values were used for the typical and
 *          best case corners.  It is recommended that critical timing and
 *          setup and hold times be checked at all corners.
 *
 *      Known Bugs: None.
 *
 *      Known Work Arounds: N/A
 *
 */

MODEL
MODEL_VERSION "1.0";
DESIGN "ram_512x16";
TRIOUT Q[15:0];
INPUT A[8:0];
INPUT CEN;
INPUT CLK;
INPUT D[15:0];
INPUT WEN;
INPUT OEN;
MODE mem_mode =	Mission  COND(CEN==0);


tch_tas: SETUP(POSEDGE) A CLK MODE(mem_mode=Mission);
tch_tah: HOLD(POSEDGE) A CLK MODE(mem_mode=Mission);
tch_tcs: SETUP(POSEDGE) CEN CLK MODE(mem_mode=Mission);
tch_tch: HOLD(POSEDGE) CEN CLK MODE(mem_mode=Mission);
tch_tds: SETUP(POSEDGE) D CLK MODE(mem_mode=Mission);
tch_tdh: HOLD(POSEDGE) D CLK MODE(mem_mode=Mission);
tch_tws: SETUP(POSEDGE) WEN CLK MODE(mem_mode=Mission);
tch_twh: HOLD(POSEDGE) WEN CLK MODE(mem_mode=Mission);
period_tcyc: PERIOD(POSEDGE) CLK ;
tpw_tckh: WIDTH(POSEDGE) CLK ;
tpw_tckl: WIDTH(NEGEDGE) CLK ;
dly_tya: DELAY(POSEDGE) CLK Q  ;
dly_tlzl: DELAY(DISABLE_HIGH) OEN Q  MODE(mem_mode=Mission);
dly_tlzh: DELAY(ENABLE_LOW) OEN Q  MODE(mem_mode=Mission);
ENDMODEL
