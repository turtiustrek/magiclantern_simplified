/** \file
 * Entry points into the firmware image.
 *
 * These are the functions that we can call from our tasks
 * in the Canon 1.0.1 firmware for the EOS 200D.
 *
 */
/*
 * Copyright (C) 2018 Magic Lantern Team
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the
 * Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor,
 * Boston, MA  02110-1301, USA.
 */

#include <stub.h>

/* Using Thumb stubs everywhere to keep things simple. The Thumb bit needs to be enabled manually. */

/** Startup **/
NSTUB( ROMBASEADDR, firmware_entry )
THUMB_FN(0xE00400FC,  cstart)                               /* calls bzero32 and create_init_task(..., init_task, ...) */
THUMB_FN(0xDF00D298,  bzero32)                              /* zeros out a data structure */
THUMB_FN(0xDF006514,  create_init_task)                     /* low-level DryOS initialization */
THUMB_FN(0xE06BE168,  dcache_clean)                         /* loop with MCR p15 c7,c10,1; DSB */
THUMB_FN(0xE06BE23C,  icache_invalidate)                    /* loop with MCR p15 c7,c5,1; c7,c1,6; c7,c1,0; ISB */
THUMB_FN(0xE0040224,  init_task)                            /* USER_MEM size checking, dmSetup, termDriverInit, stdlibSetup etc */

/** Tasks **/
DATA_PTR(    0x1010,  current_interrupt)                    /* from interrupt handler (VBAR + 0x18); where the interrupt ID is stored */
DATA_PTR(    0x1028,  current_task)                         /* from task_create; pointer to the current task structure */
THUMB_FN(0xDF00880E,  msleep)                               /* argument is always multiple of 10 */
THUMB_FN(0xDF008CE6,  task_create)                          /* used to start TaskMain, GuiMainTask etc */

/** Interrupts **/
THUMB_FN(0xE0137000,  cli_spin_lock)                        /* used in AllocateMemory/FreeMemory and others */
DATA_PTR(   0x6CC10,  isr_table_handler)                    /* from interrupt handler; address of the ISR handler */
DATA_PTR(   0x6CC14,  isr_table_param)                      /* from interrupt handler; argument of the ISR handler */
DATA_PTR(    0x4034,  post_isr_hook)                        /* from interrupt handler; called after the ISR handler */
DATA_PTR(    0x4030,  pre_isr_hook)                         /* from interrupt handler; called before the ISR handler */

/** File I/O **/
THUMB_FN(0xE04BC256, _FIO_CreateFile)
THUMB_FN(0xE04BC1EC, _FIO_OpenFile)
THUMB_FN(0xE04BC428,  FIO_CloseFile)
THUMB_FN(0xE04BC310, _FIO_ReadFile)
THUMB_FN(0xE04BC3B6, _FIO_WriteFile)
THUMB_FN(0xE04BD934,  FIO_SeekSkipFile)
THUMB_FN(0xE04BC546, _FIO_GetFileSize)
THUMB_FN(0xE04BC2C4, _FIO_RemoveFile)
THUMB_FN(0xE04BCBCA, _FIO_RenameFile)
THUMB_FN(0xE04BCD50, _FIO_CreateDirectory)
THUMB_FN(0xE04BD060, _FIO_FindFirstEx)
THUMB_FN(0xE04BD0EE,  FIO_FindNextEx)
THUMB_FN(0xE04BD15A,  FIO_FindClose)
THUMB_FN(0xE04BCE74,  FIO_Flush)                            // to be called after FIO_CloseFile?

/** GUI **/
THUMB_FN(0xE00C5414,  GUI_Control)
THUMB_FN(0xE04A7EF4,  SetGUIRequestMode)
THUMB_FN(0xE00921DC,  gui_init_end)
THUMB_FN(0xE00C526A,  gui_main_task)

/** Bitmap **/
DATA_PTR(    0xFD84,  bmp_vram_info)                        /* first VRAM buffer, used right after DISP_SetUpdateOSDVram */

/** DMA **/
THUMB_FN(0xE01B3296,  dma_memcpy)

/** Debug messages **/
THUMB_FN(0xDF006E6C,  DryosDebugMsg)                        /* lots of debug messages; format string is third argument */

/** Dumper **/
THUMB_FN(0xE007EE5A,  dump_file)                            /* tries to save a file to either "A:/%s" or "B:/%s"; calls FIO_RemoveFile/CreateFile/WriteFile/CloseFile/Flush */

/** Eventprocs (call by name) **/
THUMB_FN(0xE04BDB8E,  call)                                 /* many functions called by name (lv_start, lv_stop etc) */

/** GUI timers **/
THUMB_FN(0xE0530232,  SetHPTimerNextTick)                   /* same "worker" function as SetHPTimerAfterNow */
THUMB_FN(0xE05301DE,  SetHPTimerAfterNow)                   /* from error message */
THUMB_FN(0xE04B9984,  SetTimerAfter)                        /* from error message */
THUMB_FN(0xE05F9DB4,  CancelDateTimer)
THUMB_FN(0xE04B9A3A,  CancelTimer)                          /* from error message */

/** MPU communication **/
THUMB_FN(0xE056314E,  mpu_recv)                             // passed as last argument by InitializeIntercom and eventually stored into mpu_recv_cbr
DATA_PTR(    0x79C0,  mpu_recv_cbr)                         // mpu_recv is called indirectly through this function pointer
DATA_PTR(   0x87998,  mpu_recv_ring_buffer)                 // ring buffer used in SIO3_ISR, subroutine that processes two chars at a time
DATA_PTR(    0x799C,  mpu_recv_ring_buffer_tail)            // ring buffer index incremented in the above subroutine
THUMB_FN(0xE01C7656,  mpu_send)                             // "dwSize < TXBD_DATA_SIZE"
DATA_PTR(   0x87AD8,  mpu_send_ring_buffer)                 // ring buffer used in mpu_send
DATA_PTR(    0x79A4,  mpu_send_ring_buffer_tail)            // ring buffer index incremented in mpu_send

/** Memory allocation **/
THUMB_FN(0xDF007B58, _AllocateMemory)                       /* "NG AllocateMemory" */
THUMB_FN(0xDF007D10, _FreeMemory)                           /* from context; worker function operates on the same memory pool */
THUMB_FN(0xDF0079E2,  GetMemoryInformation)                 /* called from AllocateMemory */
THUMB_FN(0xDF0079B6,  GetSizeOfMaxRegion)                   /* same */
THUMB_FN(0xDF00AC54, _alloc_dma_memory)                     /* calls AllocateMemory(size + 64), aligns the pointer, makes it uncacheable, syncs caches */
THUMB_FN(0xDF00AC80, _free_dma_memory)                      /* opposite of the above */
THUMB_FN(0xE0693B22, _malloc)                               /* "can't malloc" */
THUMB_FN(0xE0693B5A, _free)                                 /* from context */

/** Memory info **/
THUMB_FN(0xE023D3C8,  malloc_info)                          /* Malloc Information */
THUMB_FN(0xE01CA9C8,  memmap_info)                          /* Exception vector, DRYOS system memory etc */
THUMB_FN(0xE0148E3A,  smemShowFix)                          /* Common Lower, Common Upper etc */
THUMB_FN(0xE023D460,  sysmem_info)                          /* System Memory Information */

/** Misc **/
THUMB_FN(0xE11C7CF8,  vsnprintf)                            /* called near dmstart; references "01234567", "0123456789", "0123456789abcdef" and "0123456789ABCDEF"; second arg is size; the one called by DebugMsg only knows %s */
NSTUB(0x401038C3, uart_printf)

/** Sockets **/
THUMB_FN(0xe071d880,socket_create);
THUMB_FN(0xe071d8b8,socket_bind);
THUMB_FN(0xe071d8f2,socket_connect);
THUMB_FN(0xe071d92c,socket_listen);
THUMB_FN(0xe071db7a,socket_shutdown);
THUMB_FN(0xe071d960,socket_accept);
THUMB_FN(0xe071d99a,socket_recv);
THUMB_FN(0xe071d9d8,socket_recvfrom);
THUMB_FN(0xe071da20,socket_send);
THUMB_FN(0xe071da3a,socket_sendto);
THUMB_FN(0xe071da80,socket_setsockopt);
THUMB_FN(0xe071dac4,socket_getsockopt);
THUMB_FN(0xe0714a20,socket_close_caller);
THUMB_FN(0xe07321f4,socket_convertfd); 
THUMB_FN(0xe0714b1c,socket_select_caller); /* not the actual select function as this needs the fd converted */

THUMB_FN(0xE036D59C,wlanconnect);

// SJE unsure stuff: currently majority copied from 50D (I have roms for this),
// or 100D (more modern, presumably sort of similar)
//
// Alex recommended making a dummy function for stubs that can't be located,
// and leaving the stub blank.  50D does this in misc.c (can choose a better name)

// UNSURE or untested
NSTUB(0xdf0031a3,  task_info_by_id) // called indirectly by task_create and functions using string "TASK Name"
NSTUB(0xe023ccc7,  is_taskid_valid) // probably wrong
NSTUB(    0x4ea4,  dm_names) // in DebugMsg, before the 1st loop target
NSTUB(   0x1fd7c,  sd_device) // in sdReadBlk, probably 0xe02b6fa2.  Lots of refs
                              // to 0x1fd7c, some to 0x1fd80
NSTUB(    0x4844,  gui_main_struct) // in gui_main_task, 0xe00c527c, load reg after bl gui_init_end
                                    // or possibly 0x4838 - this looks to be the start of the struct
NSTUB(0xe00c54ab,  GUI_ChangeMode) // "GUI_ChangeMode:%d" string
NSTUB(0xe04b907d,  DispSensorStart) // 0xe794 looks to be a bool for whether Sensor is started
NSTUB(0xe04ba81d,  DeleteMemorySuite)
NSTUB(0xe04baa5c,  CreateMemorySuite)
NSTUB(0xe04b9f88,  CreateMemoryChunk) // called from CreateMemorySuite
//NSTUB(0xe04ba7e6,  GetSizeOfMemorySuite) // not needed, but I found it along the way
NSTUB(0xdf008514,  take_semaphore) // Fairly sure. Same function sig and followed by give_semaphore
NSTUB(0xdf00858f,  give_semaphore)
NSTUB(0xdf008419,  create_named_semaphore) // also see df00b114, very similar, but 8418 is closer to 50D create_named_semaphore
NSTUB(0xe02d35aa,  gui_change_mode) // GUI_ChangeMode_Post
NSTUB(0xe00c55b7,  gui_massive_event_loop) // GUI_Control_Post string.  Calling convention differs on 200D vs 50D
NSTUB(0xe00979d8,  gui_init_event) // "-> handleGuiInit"
NSTUB(0xe04ba537,  AddMemoryChunk) // called before " 32(Src,bytes,Unit)=(%#lx,%#lx,%#lx)" in many places; see also hAddSuite
                                   // maybe 0xe04ba536? Similar, except it returns void, not int.
                                   // Also see 0xe04ba494, v. similar but diff struct offsets
NSTUB(0xe04ba5bb,  GetFirstChunkFromSuite)                  // AJ_PackMemory_PackMem_p3
NSTUB(0xe04bae8b,  GetNextMemoryChunk)                      // AJ_PackMemory_PackMem.c_IsChunkSignature_p2
NSTUB(0xe04ba3d5,  GetMemoryAddressOfMemoryChunk)           // AJ_PackMemory_PackMem.c_IsChunkSignature - 200D uses "MemChunk" directly
NSTUB(0xe062df0a,  AllocateMemoryResource)                  // m_pfAllocMemoryCBR, this function takes 4 params in 200D, 3 for 50D
NSTUB(0xe062df38,  AllocateContinuousMemoryResource)        // m_pfContAllocMemoryCBR, takes 4 params now, 3 for 50D
NSTUB(0xe062dfde,  FreeMemoryResource)                      // m_pfFreeMemoryCBR
NSTUB(0xdf00b1d8,  msg_queue_receive) // "SystemIF::KerQueue.c" useful for finding some of these msg_ functions
NSTUB(0xdf00b26b,  msg_queue_post)
NSTUB(0xdf00b17d,  msg_queue_count) // Above "!!!!!!! QUE Overflo" - maybe 0xdf00b17c.  Not sure here,
                                    // params looks weird but I think decompilation may have confused
                                    // stack variables with params.  Code itself similar.
NSTUB(0xdf00b615,  msg_queue_create) // CreateMessageQueue - In 50D, msg_queue_create calls 0xff866424,
                                     // the equiv of which is 0xdf00b114 (and was easier to find)
NSTUB(0xe04bba44,  prop_deliver)
NSTUB(0xe04bbde0,  prop_register_slave) // called by"GUI_RegisterPropertySlave"
NSTUB(0xe0381ba8,  LiveViewApp_handler) // not sure - function is quite different 50D -> 200D, but that
                                        // doesn't seem unreasonable since large GUI changes.  String use and surrounding
                                        // functions look similar / related.
NSTUB(0xe046fc48,  PlayMain_handler) // "DlgPlayMain.c PRESS_ERASE_BUTTON" - code above the string, wasn't found automatically
NSTUB(0xe0354327,  GetCFnData) // "GetCFnData" Function sig is different but the body looks similar
NSTUB(0xdeadbeef,  SetCFnData) // No string refs, but 200D doesn't have C1 on main dial, maybe no custom functions?
NSTUB(0xe069ce15,  GUI_SetLvMode) // "GUI_SetBracketReset"
NSTUB(0xe0693b22, _malloc) // These two names are used in 50D and CONFIG_HELLO_WORLD won't build without them,
NSTUB(0xe0693b5a, _free)   // however, the inital stubs for 200D call these simply malloc/free.
                           // I'm leaving them defined with both names, although that seems wrong.
NSTUB(0xe04cff72,  SRM_AllocateMemoryResourceFor1stJob) // "hJobMemorySuite" strings, function a little earlier
NSTUB(0xe04d2fec,  SRM_FreeMemoryResourceFor1stJob) // find refs to "pMessage", there are several similar looking functions using it,
                                                    // this is my best guess
NSTUB(0xe04bbad7, _prop_cleanup) // "./Multicast/PropertyMgr.c" check funcs that ref this string
NSTUB(0xdf00b67d,  CreateRecursiveLock) // via "KerRLock.c", CRL() calls a function that regs this string, not many do
NSTUB(0xdf00b451,  AcquireRecursiveLock)
NSTUB(0xdf00b51b,  ReleaseRecursiveLock)
NSTUB(0xe04b1d75,  dialog_redraw) // Found via checking xrefs to "pDialog->pSignature == pcSignature"
NSTUB(0xe04b3738,  CreateResLockEntry) // via xrefs to a pointer to "ResInfo"
NSTUB(0xe04b3b59,  LockEngineResources) //  Down a bit from CreateResLockEntry, start v similar but end is different.
NSTUB(0xe06217f0,  ErrForCamera_handler) // ERR70, ERR80 etc (DlgErrForCamera.c, AJ_DIALOG.HANDLER_DlgErrForCamera.c)
NSTUB(0xdf00d365,  fsuDecodePartitionTable) // this is called in one place in 50D, 0xffb0a18c,
                                            // and that function is easy to find in 200D via "CARD_EMERGENCY_STOP".
                                            // The function called 200D looks a lot different from fsuDecodePartitionTable, however.
                                            // Constant offsets used are the same in both, maybe fsuDPT has been partially 
                                            // inlined in 200D?  The decompilation looks weird too, claims it just returns
                                            // the calling param but it clearly twiddles some registers.
                                            // TODO check how ML uses this stub, since the sig has changed.
NSTUB(0xe05f67d0,  ShootOlcApp_handler) // near "StopShootOlcApp PopPalette(%d)"
NSTUB(    0xfc88,  gui_task_list) // "pDialog" strings often have refs to 0xfcb4, if so, should be
                                  // around 20 before that? "pDeleteController->psSignature" also distinctive.
                                  // Found in function 0xe0660c90.
NSTUB(0xe05cd1fe, _LoadCalendarFromRTC) // 0xff885058 in 50D is 0xe00742fc in 200D.  In 50D this calls
                                        // LoadCalendarFromRTC, which takes one arg, the first local var;
                                        // but really this is a local struct of six fields, ie, the next 5 locals
                                        // are initialised by the call (Ghidra can't work out func takes pointer to struct?).
                                        // In 200D a function is called which does take the first local var,
                                        // along with initialising the next 5.  But this function takes 4 other args,
                                        // and the code within looks really different.  One of those args is a pointer to function,
                                        // with that function being semaphore related.  Multi-core sync stuff?  Could
                                        // make sense given RTC related.

// WRONG but partially found
NSTUB(   0xfd84,  bmp_vram_info) // function e04a044c looks relevant, see refs to 0x3c0 and 0x21c; 960x540
                                 // 0xfda0 seems bool for whether it's in 960x540 or 720x480.
                                 // 0xfd70 looks like a struct base, at the end of this func
                                 // you can see fd70 + 0x14, 0x18, 0x1c being used to see which vram buffer
                                 // is active, or ready maybe.
                                 // However, I'm confused by the vram.h bmp_vram_info struct def.
                                 // Don't see how it relates.


// WRONG
//NSTUB(   0x1D6FC,  cf_device) // in cfReadBlk - probably this is 0xe0400446, but, in 200D,
                              // the struct offset looks to be passed in as r0, and I don't see
                              // the function called from anywhere so I can't work that out yet.
                              // Probably not needed; 200D doesn't have CF.


NSTUB(   0x242C0,  LCD_Palette) // in InitializeBitmapDisplayDevice, right after 0xc0f14800
//NSTUB(    0x30F8,  task_max)
//NSTUB(    0x1934,  task_dispatch_hook)
//NSTUB(    0x3960,  gui_timer_struct) // in GUI_Control_Post
//NSTUB(    0x7674,  mvr_config)
//NSTUB(0xC0220000,  camera_engine)
//NSTUB(0xDEADBEEF,  ErrCardForLVApp_handler)
NSTUB(0xDEADBEEF,  PlayMovieGuideApp_handler) // needed for CONFIG_QEMU
NSTUB(    0xFF3C,  additional_version)
//NSTUB(0xFF8542C4,  PowerAudioOutput)
//NSTUB(0xFF85460C,  SetAudioVolumeOut)
//NSTUB(0xFF855290,  SetSamplingRate)
THUMB_FN(0xE04BB5AC, _prop_request_change)
//NSTUB(0xFF85E90C,  EnableImagePhysicalScreenParameter)
//NSTUB(0xFF863E5C,  dm_set_store_level) // called by "dmstore"
//NSTUB(0xFF86F990,  task_trampoline)
//NSTUB(0xFF8898CC,  gui_local_post)
//NSTUB(0xFF889CA8,  gui_other_post)
//NSTUB(0xFF889DCC,  gui_post_10000085) // should be called post 100000a5 no ? <-- not sure what this means.
//NSTUB(0xFF889E80,  gui_change_shoot_type_post)
//NSTUB(0xFF889F18,  gui_change_lcd_state_post)
//NSTUB(0xFF98A990,  gui_timer_something)
//NSTUB(0xFF968690,  mvrSetDefQScale)
//NSTUB(0xFF9686C8,  mvrSetFullHDOptSize)
//NSTUB(0xFF968874,  mvrFixQScale)

// SJE maybe 0xe007e056 is important.  This loops doing a "DmacCh" related function, and that gets us
// to 0x36bf0 - there's a few functions there that ref edmac related strings!
// 
//NSTUB(0xFF97C8D4,  SetEDmac)
//NSTUB(0xFF97C8F0,  ConnectWriteEDmac)
//NSTUB(0xFF97C918,  ConnectReadEDmac)
//NSTUB(0xFF97C938,  StartEDmac)
//NSTUB(0xFF97C9E4,  AbortEDmac)
//NSTUB(0xFF97CA84,  RegisterEDmacCompleteCBR)
//NSTUB(0xFF97CA98,  UnregisterEDmacCompleteCBR)
//NSTUB(0xFF97CAAC,  RegisterEDmacAbortCBR)
//NSTUB(0xFF97CAE4,  UnregisterEDmacAbortCBR)
//NSTUB(0xFF97CB14,  RegisterEDmacPopCBR)
//NSTUB(0xFF97CB28,  UnregisterEDmacPopCBR)
//NSTUB(0xFF97D794, _EngDrvOut)
//NSTUB(0xFF97D7F8,  shamem_read) // AJ_0x8FB0_engio_struct_n_R0_manipulation_to_get_ptr
//NSTUB(0xFF97D904, _engio_write)
//NSTUB(0xFFA6CE4C,  UnLockEngineResources)

// SJE couldn't find it, some other cameras don't have it, looks like
// audio-common.c has a static array for that.
//NSTUB(0xFF4C466C,  audio_thresholds) // after ptr to "ALVFactorySemSignature"

// SJE not required to build CONFIG_HELLO_WORLD
//NSTUB(0xFF063AA8, _audio_ic_read)
//NSTUB(0xFF063BF4, _audio_ic_write)
//NSTUB(0xFF2045E0,  GUI_SetRollingPitchingLevelStatus)
//NSTUB(0xFF4B39AC,  lv_path_struct)
//NSTUB(0xFF2CFA54,  MirrorDisplay)
//NSTUB(    0x1ED0,  sounddev) // in sounddev_task
//NSTUB(0xFF0537D4,  sounddev_active_in)
//NSTUB(0xFF05346C,  sounddev_task)
//NSTUB(0xFF2CFAB4,  NormalDisplay)
//NSTUB(0xFF2CFA84,  ReverseDisplay)
//NSTUB(0xFF852494,  StartASIFDMADAC)
//NSTUB(0xFF852A80,  StopASIFDMADAC)
//NSTUB(0xFF051950,  StartASIFDMAADC)
//NSTUB(0xFF052088,  SetNextASIFADCBuffer)
//NSTUB(0xFF0521CC,  SetNextASIFDACBuffer)
//NSTUB(0xFF2FDEF8,  HideUnaviFeedBack_maybe)
//NSTUB(0xFF1AA6C8,  mvrSetGopOptSizeFULLHD)
//NSTUB(0xFF9A474C,  GUI_SetMovieSize_a)
//NSTUB(0xFF9A4848,  GUI_SetMovieSize_b)
//NSTUB(0xFF9ED888,  ptp_register_handler)
//NSTUB(0xFF3010F4,  LiveViewApp_handler_BL_JudgeBottomInfoDispTimerState)
//NSTUB(0xFF30204C,  LiveViewApp_handler_end)
//NSTUB(0xFFAAB654,  dialog_set_property_str)
