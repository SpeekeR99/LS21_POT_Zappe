# Simple Calculator

## Project Description
This project implements a simple calculator that performs basic arithmetic operations (+, –, ×, /) with `int16` numbers.
The calculator accepts inputs in the format such as `25+66=`, `33–12=`, `18×6=`, `77/7=` and displays the result.
After displaying the result, the program waits for another input.

## Functionality
- **Supported operations**: addition, subtraction, multiplication, and division.
- **Input format**: `number1 operator number2 =` (e.g., `25+66=`).
- **Output**: The result of the operation is displayed, and the program waits for the next input.

## Algorithm
1. **Reading Input**:
   - The input is stored in memory at address `vstup`.
   - The data is split into the first number (`cis1`), second number (`cis2`), and operator (`znamenko`).
2. **Processing the operation**:
   - The operator is converted to a symbolic value:
     - `+` → 1
     - `–` → 2
     - `×` → 3
     - `/` → 4
   - The numbers are converted from ASCII to numeric values.
3. **Calculating the result**:
   - The required arithmetic operation is performed.
   - The result is converted back to ASCII and stored in memory at address `vysledek`.
4. **Displaying the result**:
   - The result is displayed using the simulated output (syscall `PUTS`).
   - The program returns to the beginning and waits for the next input.

## Memory Structure
| Variable      | Memory Address |
|---------------|----------------|
| vstup         | FF4000         |
| vyzva         | FF4014         |
| odpoved       | FF4024         |
| cis1          | FF4032         |
| cis2          | FF4034         |
| vysledek      | FF4036         |
| znamenko      | FF403B         |
| par_vyzva     | FF403C         |
| par_vstup     | FF4040         |
| par_vystup    | FF4044         |
| par_odpo      | FF4048         |
| stck          | FF40B0         |

## Subroutines
### 1. **vynulujReg**
Clears all registers (except ER7) using the `xor.l` instruction.

### 2. **nacti**
Reads the input data:
- Identifies the first number (`cis1`), operator (`znamenko`), and second number (`cis2`).
- Converts ASCII values to numeric values.

### 3. **vypis**
Handles the result output:
- Converts the numerical result back to ASCII.
- Stores the result in memory and adds a newline (`0x0A`).

## Technologies Used
- The program is written in low-level assembly language for a simulated processor.
- Inputs and outputs are handled using syscalls (`GETS`, `PUTS`) and memory addressing.

## How to Run
1. Load the program into a processor simulator that supports the given instructions.
2. Run the program and enter an example in the format `number1 operator number2 =`.
3. The result will be displayed, and you can enter another example.
