# Assembly-Language Multi-Game Arcade Emulator

This project is a multi-game arcade emulator written in **Assembly language**, designed to run in a DOS environment. It includes three classic games: **Space Car**, **Snake**, and **Rapid Roll**. Each game is implemented in Assembly, showcasing low-level programming techniques, efficient use of system resources, and direct hardware manipulation. This project is an excellent example of how Assembly language can be used to create interactive and performant applications.

## Table of Contents
1. [Project Overview](#project-overview)
2. [Games Included](#games-included)
   - [Space Car](#space-car)
   - [Snake](#snake)
   - [Rapid Roll](#rapid-roll)
3. [Technical Details](#technical-details)
   - [Assembly Language](#assembly-language)
   - [BIOS Interrupts](#bios-interrupts)
   - [Direct Hardware Access](#direct-hardware-access)
4. [Compilation and Execution](#compilation-and-execution)
   - [Prerequisites](#prerequisites)
   - [Running the Games](#running-the-games)
   - [Compilation Instructions (Optional)](#compilation-instructions-optional)
5. [Project Structure](#project-structure)
6. [Development Environment](#development-environment)
7. [Contributing](#contributing)
8. [License](#license)
9. [Acknowledgments](#acknowledgments)

---

## Project Overview

This project is a collection of classic arcade games implemented in **Assembly language**. The goal is to demonstrate the power and efficiency of low-level programming while providing a fun and nostalgic gaming experience. Each game is designed to run in a DOS environment, leveraging **BIOS interrupts** and **direct hardware manipulation** for optimal performance.

<div align="center">
  <img src="images/Menu interface.png" alt="Multi-Game Arcade Menu" width="400"/>
</div>

The project includes:
- **Space Car:** A fast-paced game where the player controls a spaceship, avoiding asteroids and collecting coins.
- **Snake:** A classic game where the player controls a growing snake, collecting food while avoiding collisions.
- **Rapid Roll:** A ball-rolling game where the player navigates through colored blocks with different effects.

---

## Games Included

### Space Car
**File:** `SPACECAR.ASM`

<div align="center">
  <img src="images/Space Car.png" alt="Space Car Game Screenshot" width="600"/>
</div>

Space Car is a fast-paced arcade game where the player controls a spaceship, avoiding asteroids and collecting coins. The game features:
- **Dynamic Difficulty:** The speed of the game increases as the player progresses through levels.
- **Lives and Score:** Players start with 3 lives and can collect hearts to gain additional lives (up to 5 maximum).
- **Power-ups:** Collect coins for points and hearts for extra lives.
- **Level System:** Use Up/Down arrows to increase/decrease difficulty level, affecting game speed.
- **Controls:** 
  - Left/Right arrows: Move the spaceship
  - Up/Down arrows: Increase/Decrease level (speed)
  - `P`: Pause the game
  - `ESC`: Exit the game
- **Randomization:** Asteroids, coins, and hearts are randomly generated, ensuring a unique experience each time.

### Snake
**File:** `snake.asm`

<div align="center">
  <img src="images/Snake Game.png" alt="Snake Game Screenshot" width="600"/>
</div>

Snake is a classic game where the player controls a growing snake, collecting food while avoiding collisions with the walls and its own tail. The game features:
- **VGA Graphics:** 320x200 resolution with 256 colors for enhanced visual experience.
- **Score System:** Points are awarded for each piece of food collected (10 points per food).
- **Lives:** Players start with 3 lives, and the game ends when all lives are lost.
- **Growing Snake:** The snake grows longer with each piece of food collected, increasing the difficulty.
- **Sound Effects:** PC speaker sound effects for game events.
- **Controls:** 
  - Arrow keys: Change the snake's direction
  - `A`: Show game information
  - `P`: Pause the game
  - `ESC`: Exit the game

### Rapid Roll
**File:** `RR.asm`

<div align="center">
  <img src="images/Rapid Roll.png" alt="Rapid Roll Game Screenshot" width="600"/>
</div>

Rapid Roll is an exciting ball-rolling game where the player controls a ball that rolls down through various colored blocks. The game features:
- **Health System:** Players start with 3 lives and must avoid dangerous blocks.
- **Colored Blocks with Different Effects:**
  - **Red Blocks:** Decrease health by 1 (dangerous - avoid these!)
  - **Green Blocks:** Increase health by 1 (beneficial - collect these!)
  - **Pink/Magenta Blocks:** Neutral - no effect on health
  - **Cyan Blocks:** Neutral - no effect on health
- **Dynamic Gameplay:** Blocks appear randomly as the ball rolls down.
- **Score System:** Points are awarded for successfully navigating through levels.
- **Increasing Difficulty:** Game speed increases as score gets higher.
- **Controls:** 
  - `A`: Move ball left
  - `D`: Move ball right
  - `E`: Exit/Forfeit the game
  - `P`: Play again (when game over)
  - `X`: Exit to DOS (when game over)

---

## Technical Details

### Assembly Language
The games are written in **x86 Assembly language**, which allows for direct control over the CPU and hardware. Assembly language is used for its efficiency and low-level access, making it ideal for performance-critical applications like games.

### BIOS Interrupts
The games use **BIOS interrupts** for tasks such as:
- **Keyboard Input:** Reading player input using interrupt `INT 16H`.
- **Video Output:** Displaying graphics and text using interrupt `INT 10H`.
- **Timing:** Managing game timing and delays using interrupt `INT 1AH`.
- **DOS Services:** Using interrupt `INT 21H` for various system functions.

### Direct Hardware Access
The games directly access hardware components such as:
- **Video Memory:** Writing directly to the video memory at segment `0xA000` for fast graphics rendering.
- **VGA Ports:** Direct manipulation of VGA registers for palette and display control.
- **Sound:** Generating sound effects using the PC speaker and timer interrupts.
- **Real-time Clock:** Using system timer for game timing and random number generation.

---

## Compilation and Execution

### Prerequisites
- **DOSBox:** To run the games in a DOS environment.
- **MASM (Microsoft Macro Assembler):** To compile the Assembly code (if you want to modify and recompile the games).
- **LINK.EXE:** To link the object files and generate executables.

### Running the Games
1. **Launch DOSBox.**
2. **Mount the Project Directory:**
   - In DOSBox, type the following command to mount the project directory as the `C:` drive:
     ```bash
     mount c /path/to/your/project/directory
     ```
     Replace `/path/to/your/project/directory` with the absolute path to your project folder.
     
     **Example:**
     ```bash
     mount c C:\Users\YourName\Assembly-language-multi-game-arcade-emulator
     ```
3. **Switch to the C: Drive:**
   - After mounting, switch to the `C:` drive by typing:
     ```bash
     c:
     ```
4. **Navigate to Source Directory:**
   - Change to the source directory:
     ```bash
     cd src
     ```
5. **Run the Menu:**
   - To launch the game menu, type:
     ```bash
     menu.bat
     ```
   - A menu will appear with options to select and play any of the three games:

<div align="center">
  <img src="images/Menu interface.png" alt="Game Menu Interface" width="500"/>
</div>

   - **Space Car**
   - **Snake** 
   - **Rapid Roll**

### Compilation Instructions (Optional)
If you want to modify and recompile the games, follow these steps:
1. Open DOSBox and navigate to the project directory as described above.
2. Use the following commands to compile each game:
   - **Space Car:**
     ```bash
     masm SPACECAR.ASM;
     link SPACECAR.OBJ;
     ```
   - **Snake:**
     ```bash
     masm snake.asm;
     link snake.obj;
     ```
   - **Rapid Roll:**
     ```bash
     masm RR.asm;
     link RR.obj;
     ```

---

## Project Structure

```
Assembly-language-multi-game-arcade-emulator/
├── src/
│   ├── SPACECAR.ASM          # Space Car game source code
│   ├── SPACECAR.EXE          # Space Car compiled executable
│   ├── snake.asm             # Snake game source code
│   ├── snake.com             # Snake compiled executable
│   ├── RR.asm                # Rapid Roll game source code
│   ├── RR.EXE                # Rapid Roll compiled executable
│   ├── COMPILE.BAT           # Batch file for compiling all games
│   ├── MENU.BAT              # Batch file for launching the game menu
│   ├── MENU.ASM              # Source code for the game menu
│   ├── MENU.EXE              # Compiled game menu executable
│   ├── MASM.EXE              # Microsoft Macro Assembler
│   ├── TASM.EXE              # Turbo Assembler (alternative)
│   ├── LINK.EXE              # Linker for generating executables
│   ├── TLINK.EXE             # Turbo Linker (alternative)
│   ├── DEBUG.EXE             # Debugging tool for Assembly programs
│   ├── EDIT.COM              # DOS text editor
│   └── All_code.txt          # Concatenated source code for all games
├── README.md                 # Project documentation
```

---

## Development Environment

The project was developed using the following tools:
- **MASM (Microsoft Macro Assembler):** For assembling the Assembly code.
- **TASM (Turbo Assembler):** Alternative assembler for some components.
- **DOSBox:** For testing and running the games in a DOS environment.
- **DOS EDIT:** For editing the Assembly source code in the DOS environment.
- **DEBUG.EXE:** For debugging the Assembly programs.

---

## Contributing

Contributions are welcome! If you'd like to add a new game, improve existing code, or fix bugs, please follow these steps:
1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Commit your changes and push to the branch.
4. Submit a pull request with a detailed description of your changes.

### Development Guidelines
- Follow the existing code style and commenting conventions.
- Test your changes thoroughly in DOSBox before submitting.
- Ensure compatibility with the existing menu system.
- Document any new features or controls in the README.

---

## License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for more details.

---

## Acknowledgments

- **Contributors:** Reshad Ul Karim, Sammam Mahdi, Meherab Hossain
- **CSE341 Course:** This project was developed as part of the CSE341 coursework.
- **DOSBox Team:** For providing a reliable DOS emulator for testing.
- **Assembly Language Community:** For their resources and support in learning Assembly programming.
- **BRACU CSE Department:** For the educational support and guidance.

---

Enjoy the games and happy coding!