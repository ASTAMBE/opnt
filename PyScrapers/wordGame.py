import tkinter as tk
from tkinter import messagebox
import random
import time
import json
from datetime import datetime

# Sample word list (expand this with a real dictionary)
word_list = ["jumping", "scrambled", "delighted", "running", "finished", "exploring"]


class WordJumbleApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Word Jumble Game")

        # Game state
        self.current_word = ""
        self.scrambled_word = ""
        self.guess = []
        self.start_time = 0
        self.history = self.load_history()

        # UI Elements
        self.tiles_frame = tk.Frame(root)
        self.tiles_frame.pack(pady=10)

        self.guess_label = tk.Label(root, text="Your Guess: ", font=("Arial", 14))
        self.guess_label.pack(pady=5)

        self.time_label = tk.Label(root, text="Time: 0s", font=("Arial", 12))
        self.time_label.pack(pady=5)

        self.submit_button = tk.Button(root, text="Submit", command=self.check_guess)
        self.submit_button.pack(pady=5)

        self.reset_button = tk.Button(root, text="Reset", command=self.reset_guess)
        self.reset_button.pack(pady=5)

        self.new_game_button = tk.Button(root, text="New Game", command=self.new_game)
        self.new_game_button.pack(pady=5)

        # Start the first game
        self.new_game()
        self.update_timer()

    def new_game(self):
        # Pick and scramble a word
        self.current_word = random.choice(word_list)
        self.scrambled_word = ''.join(random.sample(self.current_word, len(self.current_word)))
        self.guess = []
        self.start_time = time.time()

        # Clear previous tiles
        for widget in self.tiles_frame.winfo_children():
            widget.destroy()

        # Create letter tiles
        for letter in self.scrambled_word:
            tile = tk.Button(self.tiles_frame, text=letter, width=2, height=1,
                             font=("Arial", 16), command=lambda l=letter: self.tile_click(l))
            tile.pack(side=tk.LEFT, padx=2)

        self.guess_label.config(text="Your Guess: ")

    def tile_click(self, letter):
        self.guess.append(letter)
        self.guess_label.config(text="Your Guess: " + ''.join(self.guess))

    def reset_guess(self):
        self.guess = []
        self.guess_label.config(text="Your Guess: ")

    def check_guess(self):
        guess_word = ''.join(self.guess)
        if guess_word == self.current_word:
            end_time = time.time()
            time_taken = round(end_time - self.start_time, 2)
            messagebox.showinfo("Success", f"Correct! Time: {time_taken}s")
            self.save_history(time_taken)
            self.new_game()
        else:
            messagebox.showerror("Wrong", "Try again!")

    def update_timer(self):
        if self.start_time:
            elapsed = round(time.time() - self.start_time, 1)
            self.time_label.config(text=f"Time: {elapsed}s")
        self.root.after(100, self.update_timer)

    def load_history(self):
        try:
            with open("history.json", "r") as f:
                return json.load(f)
        except FileNotFoundError:
            return []

    def save_history(self, time_taken):
        entry = {
            "word": self.current_word,
            "time": time_taken,
            "date": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        self.history.append(entry)
        with open("history.json", "w") as f:
            json.dump(self.history, f, indent=4)


if __name__ == "__main__":
    root = tk.Tk()
    app = WordJumbleApp(root)
    root.mainloop()