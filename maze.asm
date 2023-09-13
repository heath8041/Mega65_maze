#import "../Mega65_System/System_Macros.s"
//heath gallimore 8-28-23
//this program uses the noise generator and random output of the sid chip
//to generate a random value. then we use that value to pick / or \ to print 
//forever. this will make the random 1 line maze that is common on C64

//maze2 is a refactored version and is faster because we're printing an 
//entire line in one shot and then shifting up rather than outputing
//one char at a time

.const BOTTOM_LINE = $0F80  //$0800 screen +2000 bytes - 80 bytes to get the first pos in bottom line

System_BasicUpstart65(main) // autostart macro
*=$2015  // this is where our code will get loaded 

main:
  jsr setupSid4Noise
  lda #00 //make the back ground and border black
  sta VIC.BORDER_COLOR
  sta VIC.SCREEN_COLOR
loop:
  jsr printMazeLine
  jsr shiftLineUp
  jmp loop   //skip the jmp loop to test a single iteration
  //rts  //use the rts instead of jmp to test single interation

shiftLineUp:    //routine to shift all lines up on the screen
  ldx #00
  !:
  .for(var line=1; line<25; line++){    //unrolled code copies var 
    lda VIC.SCREEN + (line * 80), x
    sta VIC.SCREEN + (line * 80) - 80, x
  }
  inx
  cpx #80
  beq !+
  jmp !-
  !:
  rts

printMazeLine:
  ldx #00
  newChar:
    jsr getMazeChar
    sta BOTTOM_LINE, x
    inx
    cpx #80
    bne newChar
    rts

getMazeChar:
  lda SID.NOISE_OSC3_READ_ONLY //get a random value from the sid voice generator
  and #$1   //and the value in A with 1 to get odd or even value
  beq !+    //if a and 1 ==0 a = /
  lda #206  //else a=\
  jmp !++   //note this !+ and !++ notation. it just a really short label
!:
  lda #205 // a = /
!:
  rts

setupSid4Noise:
  lda #$ff   //highest value for freq
  sta SID.VOICE3_LSB_FREQ //store the highest value for random noise low byte
  sta SID.VOICE3_MSB_FREQ //store the highest value for random noise high byte
  lda #SID.WAVE_VOICE_VALUE_NOISE  //store the noise wave value, immediate
  sta SID.VOICE3_CONTROL_REG //set the voice ctrl register to the noise value
  rts