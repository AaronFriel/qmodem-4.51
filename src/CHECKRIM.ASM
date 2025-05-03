// Define the data segment for storing data used by the program
DATA   SEGMENT WORD PUBLIC
// End of data segment
DATA   ENDS

// Define the code segment for the program logic
CODE   SEGMENT WORD PUBLIC
       // Set up segment registers: CS points to CODE, DS points to DATA
       ASSUME CS:CODE, DS:DATA
       // Declare CHECKRIM as a public function accessible from other modules
       PUBLIC CHECKRIM

// Define a 4-byte identifier "NCA " used for comparison
nca_id    db   "NCA "

// CHECKRIM function: Checks for a specific hardware condition (likely related to NCA device)
// Returns: 0 if successful (good test), 1 if failed
CHECKRIM  PROC NEAR
          // Save the data segment register to restore it later
          push ds
          // Load the data segment with the address of the DATA segment
          mov  ax,seg data
          mov  ds,ax
          // Initialize BX to 0x14 - 0x8 (0x0C) for the first test
          mov  bx,14h-8
          // Call test_nca to check for NCA device at this offset
          call test_nca
          // If zero flag is set (test passed), jump to good_test
          jz   good_test

          // Initialize loop counter CX to 2 for testing additional offsets
          mov  cx,2
// Loop to test offsets 2 through 7
Loop01:   // Set BX to the current loop counter (CX)
          mov  bx,cx
          // Call test_nca to check for NCA device at this offset
          call test_nca
          // If zero flag is set (test passed), jump to good_test
          jz   good_test
          // Increment loop counter
          inc  cx
          // Compare CX with 8 (loop limit)
          cmp  cx,8
          // If CX != 8, continue the loop
          jne  Loop01
          // If all tests fail, jump to chk_rrim_end
          jmp  short chk_rrim_end

// test_nca subroutine: Tests for NCA device at a given offset in BX
test_nca: // Add 8 to BX to adjust the offset
          add  bl,8
          // Multiply BX by 4 (shift left by 2) to calculate the memory address
          shl  bx,1
          shl  bx,1
          // Clear AX (used for ES segment)
          xor  ax,ax
          // Set ES to 0 (likely accessing low memory or interrupt vector table)
          mov  es,ax
          // Load effective address from ES:[BX] into ES:BX
          les  bx,es:[bx]
          // Subtract 0x18 from BX to point to a specific location
          sub  bx,18h
          // Load word at ES:[BX+10h] into AX for comparison
          mov  ax,word ptr es:[bx+10h]
          // Compare AX with the first two bytes of nca_id ("NCA ")
          cmp  ax,word ptr cs:nca_id
          // If not equal, jump to irq_not_nca (test failed)
          jnz  irq_not_nca
          // Load word at ES:[BX+12h] into AX for second comparison
          mov  ax,word ptr es:[bx+12h]
          // Compare AX with the last two bytes of nca_id
          cmp  ax,word ptr cs:nca_id+2

// Label for failed NCA test
irq_not_nca:
          // Return from subroutine (sets zero flag based on comparison)
          ret

// Label for successful test
good_test:
          // Set AX to 0 to indicate success
          mov  ax,0
          // Jump to OK to finalize return
          jmp  short OK

// Label for failed tests (end of CHECKRIM with failure)
chk_rrim_end:
          // Set AX to 1 to indicate failure
          mov  ax,1
// Common exit point for CHECKRIM
OK:
          // Restore the data segment register
          pop ds
          // Return from CHECKRIM function
          ret
// End of CHECKRIM procedure
CHECKRIM  ENDP

// End of code segment
CODE      ENDS
// End of program
          END
