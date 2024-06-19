from enum import StrEnum
import pygame
import threading
import time


class Room(StrEnum):
    HALL = "hall"
    OFFICE = "office"
    KITCHEN = "kitchen"
    ATTIC = "attic"
    BEDROOM = "bedroom"
    GARAGE = "garage"


class Object(StrEnum):
    DRESSER = "dresser"
    FRONT_DOOR = "front_door"
    WARDROBE = "wardrobe"
    UMBRELLA = "umbrella"
    PLANT = "plant"
    PAINTING = "painting"
    OFFICE_DOOR = "office_door"
    DESK = "desk"
    CHAIR = "chair"
    COMPUTER = "computer"
    BOOKSHELF = "bookshelf"
    TABLE = "table"
    FRIDGE = "fridge"
    KITCHEN_DOOR = "kitchen_door"
    BEDROOM_DOOR = "bedroom_door"
    WINDOW = "window"
    BED = "bed"
    BESIDE_TABLE = "bedside_table"
    CLOSET = "closet"
    WIFE = "wife"
    CAR = "car"
    TOOL_SHELF = "tool_shelf"
    GARAGE_DOOR = "garage_door"
    PERSON = "person"
    ATTIC_DOOR = "attic_door"
    FABRIC = "fabric"
    CALENDAR = "calendar"
    SHOPPING_LIST = "shopping_list"
    FOLDED_NOTE = "folded_note"
    KNIFE = "knife"
    LETTER = "letter"
    PHONE = "phone"
    OFFICE_KEY = "office_key"


class Memory(StrEnum):
    REMEMBER_NAMES = "remember_names"  # Holds information about known names to a player
    REMEMBER_STRESS = "remember_stress"  # Holds information whether the player is stressed out
    FOUND_CROWBAR = "found_crowbar"  # Holds information whether the player has found the crowbar
    FOUND_BODY = "found_body"  # Holds information whether the player has found the crowbar
    FOUND_KITCHEN_NOTE = "found_kitchen_note"  # Holds information whether the player has found the note in the kitchen
    FOUND_OFFICE_KEY = "found_office_key"  # Holds information whether the player has found the note in the kitchen
    FOUND_KNIFE = "found_knife"  # Holds information whether the player has found the knife
    FOUND_BEDROOM_LETTER = "found_bedroom_letter"  # Holds information whether the player has found the letter
    FOUND_BED = "found_bed"  # Holds information whether the player has found the bed
    OPENED_OFFICE_DOOR = "opened_office_door"


class AdventureGame:
    def __init__(self):
        pygame.mixer.init()

        # Opcjonalnie do dźwięków w tle:
        background_sound_file = 'sounds/VR_background_muzyczka.wav'
        interval = 10  # Interval in seconds
        volume = 0.2

        background_sound_thread = threading.Thread(target=self.play_background_sound,
                                                   args=(background_sound_file, interval, volume),
                                                   daemon=True)
        background_sound_thread.start()

        self.current_room = Room.HALL
        self.next_to_object = Object.DRESSER
        self.rooms: dict[Room, list[Object]] = {
            Room.HALL: [
                Object.FRONT_DOOR, Object.DRESSER, Object.WARDROBE, Object.UMBRELLA, Object.PLANT, Object.PAINTING,
                Object.OFFICE_DOOR
            ],
            Room.OFFICE: [Object.OFFICE_DOOR, Object.DESK, Object.CHAIR, Object.COMPUTER, Object.BOOKSHELF],
            Room.KITCHEN: [Object.KITCHEN_DOOR, Object.TABLE, Object.FRIDGE, Object.WINDOW, Object.ATTIC_DOOR],
            Room.BEDROOM: [Object.BEDROOM_DOOR, Object.BED, Object.BESIDE_TABLE, Object.CLOSET, Object.WIFE],
            Room.GARAGE: [Object.CAR, Object.TOOL_SHELF, Object.GARAGE_DOOR],
            Room.ATTIC: [Object.PERSON, Object.ATTIC_DOOR]
        }
        self.holding: Object | None = None
        self.memory = {
            Memory.REMEMBER_NAMES: ('wife', 'guy'),
            Memory.REMEMBER_STRESS: False,
            Memory.FOUND_CROWBAR: False,
            Memory.FOUND_BODY: False,
            Memory.FOUND_KITCHEN_NOTE: False,
            Memory.FOUND_OFFICE_KEY: False,
            Memory.FOUND_KNIFE: False,
            Memory.FOUND_BEDROOM_LETTER: False,
            Memory.FOUND_BED: False,
            Memory.OPENED_OFFICE_DOOR: False
        }

    def start(self):
        self.play_sound('sounds/VR_dyszenie.wav')
        self.introduction()
        self.help()
        self.play_sound('sounds/VR_kobiecy placz i belkot .wav')
        self.command_loop()

    @staticmethod
    def play_sound(sound_file):
        if DEBUG_MODE:
            return
        sound = pygame.mixer.Sound(sound_file)
        sound.play()
        if sound_file in ('sounds/VR_kroki_krotkie.wav', 'sounds/stare skrzypiace drzwi otwieranie i zamykanie.mp3',
                          'sounds/VR_strych_dobijanie.wav', 'sounds/VR_wbieganie_po_schodach.wav',
                          'sounds/VR_mezczyzna_krzyczacy.wav', 'sounds/walking_wood_modified.mp3'):
            sound_length = sound.get_length()
            time.sleep(sound_length)

    @staticmethod
    def play_background_sound(sound_file, interval, volume):
        background_sound = pygame.mixer.Sound(sound_file)
        background_sound.set_volume(volume)
        while True:
            background_sound.play()
            time.sleep(interval)

    @staticmethod
    def introduction():
        print("I just rushed into the hallway of my house, feeling scared and confused.")
        print("Suddenly, it hit me — I can't remember why I was running or why I'm so shaky.")
        print("Maybe if I go back to the front door, I'll figure out what spooked me.")

    @staticmethod
    def help():
        print(
            "\nAvailable commands are:\n"
            "\n"
            "help                 -- to see these instructions.\n"
            "look                 -- to look around you.\n"
            "go_to Object         -- to go to the object.\n"
            "examine Object       -- to look closer at the object.\n"
            "quit                 -- to end the game and quit.\n"
            "\n"
        )

    def command_loop(self):
        while True:
            command = input("> ").strip().lower().split(" ")
            match command:
                case['help']:
                    self.help()
                case ['look']:
                    self.look()
                case ['go_to', obj]:
                    self.go_to(obj)
                case ['examine', object_name]:
                    self.examine(object_name)
                case ['save_charlie']:
                    self.save_charlie()
                case ['try_open_attic_door']:
                    self.try_open_attic_door()
                case ['look_up']:
                    self.look_up()
                case ['quit']:
                    print("Quitting the game.")
                    break
                case _:
                    print("Unknown command.")

    def look(self):
        print(f"You are at the {self.current_room}.")
        if self.next_to_object:
            print(f"There is a {self.next_to_object} next to you.")
        self.notice_objects_at(self.current_room)

    def notice_objects_at(self, place):
        print("You can see:")
        for item in self.rooms[place]:
            print(f"- {item}")

    def go_to(self, obj: Object):
        if obj in self.rooms[self.current_room]:
            if self.current_room == Room.ATTIC and obj == Room.KITCHEN:
                self.play_sound('sounds/VR_wbieganie_po_schodach.wav')
            elif self.current_room == Room.BEDROOM:
                self.play_sound('sounds/walking_carpet_2.mp3')
                self.play_sound('sounds/VR_kobiecy placz_z_bliska .wav')
            elif self.current_room == Room.ATTIC and obj == Object.PERSON:
                self.play_sound('sounds/VR_mezczyzna_krzyczacy.wav')
            else:
                self.play_sound('sounds/walking_wood_modified.mp3')

            self.next_to_object = obj
            self.interact_with(obj)
        else:
            print("This object is not nearby.")

    def interact_with(self, obj: Object):
        interactions = {
            # HALL
            Object.FRONT_DOOR: self.interact_front_door,
            Object.PLANT: lambda: self.find_note("Oh! There's a note behind the plant! 'Got home tired, found a "
                                                 "candlelit dinner in the backyard, thanks to my wife. Made my day!'"),
            Object.PAINTING: lambda: self.find_note("Oh! There's a note below the painting! "
                                                    "'Today, my wife surprised me with breakfast in bed. Waking up to "
                                                    "the smell of freshly brewed coffee and the sight of my favorite "
                                                    "pancakes made me feel incredibly loved and appreciated.'"),
            Object.DRESSER: self.find_key,
            Object.UMBRELLA: lambda: print("I found an umbrella. It's kinda useless, cause I'm inside the building."),
            Object.WARDROBE: lambda: print("There is a big old wardrobe here. "
                                           "Inside I can see coats that belong to a female."),

            # OFFICE
            Object.OFFICE_DOOR: self.try_to_open_office_door,
            Object.DESK: lambda: print("Oh! There's another note on the desk! "
                                       "'Me and my best friend had a great time in the park, laughing and snacking on "
                                       "a cozy blanket. It's moments like these that make life awesome.'"),
            Object.COMPUTER: self.explore_computer,
            Object.CHAIR: lambda: print("There is a chair here. It looks like someone was sitting here recently."),
            Object.BOOKSHELF: self.bookshelf_interaction,

            # KITCHEN:
            Object.TABLE: self.table_interaction,
            Object.FRIDGE: self.fridge_interaction,
            Object.WINDOW: lambda: print("This is kitchen window. It's pretty dark outside. "
                                         "It's hard to see what's out there."),
            Object.ATTIC_DOOR: self.attic_door_interaction,
            Object.BEDROOM_DOOR: self.interact_bedroom_door,

            # BEDROOM
            Object.BESIDE_TABLE: self.bedside_table_interaction,
            Object.CLOSET: lambda: print("I approach the closet. It is slightly open. "
                                         "Inside I see some clothes and shoes. "
                                         "But I don't plan to dressing up so... no use"),
            Object.WIFE: self.wife_interaction,
            Object.BED: self.bed_interaction,
            Object.KITCHEN_DOOR: self.kitchen_door_interaction,

            # GARAGE
            Object.CAR: lambda: print("Oh it's beautiful! 1964 Pontiac GTO... I spent hours repairing it! "
                                      "We had so many nice trips with Vanessa in this car. And with Charlie... "
                                      "I must find a tool to open that attic though, let's focus on that now."),
            Object.TOOL_SHELF: self.tool_shelf_interaction,
            Object.GARAGE_DOOR: self.garage_door_interaction,

            # ATTIC
            Object.PERSON: self.person_interaction,
            Object.FABRIC: lambda: print("This should work! Write save_charlie to use fabric to stop the bleeding.")
        }

        if action := interactions.get(obj):
            action()
        else:
            print(f"Nothing special about the {obj}.")

    def find_note(self, message):
        self.play_sound('sounds/papier - wszystkie interakcje z papierem(pytanie xd).mp3')
        print(message)

    def find_key(self):
        self.play_sound('sounds/taking key.mp3')
        print("I found a key in the drawer. I wonder what it opens.")
        self.holding = Object.OFFICE_KEY

    def interact_front_door(self):
        if not self.memory[Memory.FOUND_BODY]:
            self.play_sound('sounds/VR_strych_dobijanie.wav')
            print("Oh no! I'm trying to open the front door, but it seems like it's closed. "
                  "Maybe I'll try to look around and see if I can find some clues.")
        else:
            self.play_sound('sounds/stare skrzypiace drzwi otwieranie i zamykanie.mp3')
            print("It's open now! I run through them...")
            print("I don't even look around, I just wanna run as far as possible...")
            print("I just don't want to hear this crying anymore...")
            print("Suddenly my boots step on something hard, like wood...")
            print("I hear door closing behind me and I now know what will happen...")
            print("It will happen again... As it did so many times before...")
            self.reset_game()

    def reset_game(self):
        print("The game resets.")
        self.__init__()

    def try_to_open_office_door(self):
        if self.memory[Memory.OPENED_OFFICE_DOOR]:
            match self.current_room:
                case Room.HALL:
                    self.current_room = Room.OFFICE
                    print("You've entered the office")
                case Room.OFFICE:
                    self.current_room = Room.HALL
                    print("You've entered the hall")
        elif self.holding == Object.OFFICE_KEY:
            self.play_sound('sounds/stare skrzypiace drzwi otwieranie i zamykanie.mp3')
            print("I opened the door with the key and went inside the office. "
                  "I should look around and see what's in here.")
            self.current_room = Room.OFFICE
            self.holding = None
            self.memory[Memory.OPENED_OFFICE_DOOR] = True
        else:
            self.play_sound('sounds/VR_strych_dobijanie.wav')
            print("This door is closed. Maybe I can find some key that opens it.")

    def explore_computer(self):
        print("Exploring the computer...")
        self.play_sound('sounds/keyboard_in_front_of.mp3')
        if not self.memory[Memory.REMEMBER_NAMES][0] == 'Vanessa':
            self.play_sound('sounds/VR_odłożenie_zdjęcia.wav')
            print("I found a folder named 'Venice_2019'.")
            print("In another folder named 'My beautiful wife' I found photos of some female.")
            print("Oh god! I found a picture from the wedding! The guy she has married is me! This is my wife!")
            print("I've just recalled her name! It's Vanessa! "
                  "And the guy on previous photos is my best friend, Charlie!")
            self.memory[Memory.REMEMBER_NAMES] = ('Vanessa', 'Charlie')
            self.lock_squeaks()
        else:
            self.play_sound('sounds/VR_odłożenie_zdjęcia.wav')
            print("There are so many beautiful photos of my wife, Vanessa on this computer. I love her so much.")
            print("Oh, here is a photo of me and Charlie from our childhood. He is such a good friend of mine.")

    def lock_squeaks(self):
        if self.memory[Memory.REMEMBER_STRESS] and self.memory[Memory.REMEMBER_NAMES][0] == 'Vanessa':
            self.play_sound('sounds/VR_zamek_do_drzwi.wav')
            print("I heard a squeak from the lock. Oh, I think this sound came from the kitchen! I can go there now!")
            self.rooms[Room.OFFICE].append(Object.KITCHEN_DOOR)

    def bookshelf_interaction(self):
        print("There is a bookshelf here. There's another note here!")
        print("I have so much work to do! I can't find time for my wife... "
              "I am so stressed out that sometimes I can't control my emotions...")
        self.memory[Memory.REMEMBER_STRESS] = True
        self.lock_squeaks()

    def table_interaction(self):
        print("There is a table here. Looks like someone was preparing meat for dinner. "
              "There is a knife lying next to it.")
        self.rooms[Room.KITCHEN].append(Object.KNIFE)

    def fridge_interaction(self):
        print("This fridge is covered with colorful magnets and written notes. "
              "And there is a calendar hanging on the fridge.")
        self.rooms[Room.KITCHEN].extend([Object.CALENDAR, Object.SHOPPING_LIST, Object.FOLDED_NOTE])

    def attic_door_interaction(self):
        self.play_sound('sounds/VR_wbieganie_po_schodach.wav')
        print("There are blood stains on the door and the knob. And streaks of blood leading up to the entrance. "
              "I need to go to the attic to check what happened.")
        print("You can use new command: `try_open_attic_door`")

    def interact_bedroom_door(self):
        match self.current_room:
            case Room.BEDROOM:
                if not (self.memory[Memory.FOUND_BEDROOM_LETTER] and self.memory[Memory.FOUND_BED]):
                    print("I have to find out more...")
                else:
                    print("I should go back to the hall and then go to the garage")
                    self.current_room = Room.HALL
            case Room.HALL:
                print("Let's see what's inside the bedroom now.")
                self.current_room = Room.BEDROOM

    def bedside_table_interaction(self):
        print("I am next to the bedside_table. There is a lamp on it. And there seems to be a folded note under the "
              "lamp. Oh it is some kind of letter.")
        self.rooms[Room.BEDROOM].append(Object.LETTER)

    def wife_interaction(self):
        print("Vanessa? Vanessa, what is going on?")
        print("She is sitting on the bed, crying. I try to speak to her, but she does not respond. "
              "It seems like she cannot see me. What is happening?")
        self.next_to_object = Object.WIFE

    def bed_interaction(self):
        print("Is the bed on which Vanessa is sitting"
              "She is still crying."
              "Why did you do it?? Oh whyy"
              "I want to help her, but she is not hearing me"
              "Maybe in garage I will something to break door and go to the attic")
        self.next_to_object = Object.BED
        self.memory[Memory.FOUND_BED] = True

    def kitchen_door_interaction(self):
        self.next_to_object = Object.KITCHEN_DOOR
        match self.current_room:
            case Room.OFFICE:
                print("Let's go to the kitchen!")
                self.play_sound('sounds/VR_zamek_do_drzwi.wav')
                self.current_room = Room.KITCHEN
            case Room.KITCHEN:
                if not (self.memory[Memory.FOUND_KITCHEN_NOTE] and self.memory[Memory.FOUND_KNIFE]):
                    print("I have to find out more before I will go somewhere else...")
                else:
                    print("Let's go back to the hall and then I will go to the bedroom.")
                    self.rooms[Room.HALL].append(Object.BEDROOM_DOOR)
                    self.current_room = Room.HALL
                    print("You've entered the hall")

    def tool_shelf_interaction(self):
        print("There are piles of screws and scraps of papers. Crap, I am not a tidy person, "
              "I hope I will find something though. Oh yes! Between hammers I found a crowbar! "
              "That should do it! Now I can use this to open the attic door...")
        self.memory[Memory.FOUND_CROWBAR] = True

    def garage_door_interaction(self):
        self.play_sound('sounds/stare skrzypiace drzwi otwieranie i zamykanie.mp3')
        match self.current_room:
            case Room.GARAGE:
                if self.memory[Memory.FOUND_CROWBAR]:
                    print("Let's go to that attic now...")
                    self.current_room = Room.KITCHEN
                else:
                    print("I have to find something to open that attic door first...")
            case Room.HALL:
                print("You have entered the garage.")
                self.current_room = Room.GARAGE

    def person_interaction(self):
        print("No, no, NO! It's Charlie! He's all covered in blood... He's got two... no, three wounds in his chest... "
              "Blood is oozing from cuts, contrasting with his pale skin... "
              "I have to find something to stop the bleeding!")
        self.rooms[Room.ATTIC].append(Object.FABRIC)

    def try_open_attic_door(self):
        if self.memory[Memory.FOUND_CROWBAR]:
            self.play_sound('sounds/ciecie drewna - dostanie sie na strycxh.mp3')
            print("It was a struggle but I managed to open it. I can enter the attic now...")
            self.current_room = Room.ATTIC
        else:
            self.play_sound('sounds/VR_strych_dobijanie.wav')
            print("I try to open the door, but it is locked. The door seems to be jammed. "
                  "I need something to pry it open. Maybe in the garage I will find something to open it")
            self.rooms[Room.HALL].append(Object.GARAGE_DOOR)

    def examine(self, object_name: Object):
        examinations = {
            Object.CALENDAR: self.examine_calendar,
            Object.SHOPPING_LIST: self.examine_shopping_list,
            Object.FOLDED_NOTE: self.examine_folded_note,
            Object.KNIFE: self.examine_knife,
            Object.LETTER: self.examine_letter,
            Object.WIFE: lambda: print("Vanessa! Can you hear me?"),
            Object.CAR: lambda: print("The car is locked, I must have left the keys somewhere. "
                                      "It's not important now, let's find a way to open that attic."),
            Object.TOOL_SHELF: lambda: print("There are piles of screws and scraps of papers. "
                                             "Crap, I am not a tidy person, I hope I will find something though. "
                                             "Oh yes! Between hammers I found a crowbar! That should do it! "
                                             "Now I can use this to open the attic door..."),
            Object.PERSON: lambda: print("He's holding a phone... I remember now - he tried showing me something... "
                                         "Probably evidence of their betrayal... Yes, let's see their texts..."
                                         ) or self.rooms[Room.ATTIC].append(Object.PHONE),
            Object.PHONE: self.examine_phone
        }
        action = examinations.get(object_name)
        if action:
            action()
        else:
            print(f"I think it is just the {object_name.replace('_', ' ')}. Nothing more to see here")

    def examine_calendar(self):
        if self.next_to_object == Object.FRIDGE:
            self.play_sound('sounds/calendar_modified.mp3')
            print("It is a calendar with a fun photo of a dog. Today's date is circled in red with Charlie's name. "
                  "Maybe he is coming here today. I would love to see my dear friend")
        else:
            print("It was on the fridge. I need to go to the fridge first")

    def examine_shopping_list(self):
        if self.next_to_object == Object.FRIDGE:
            print("It is a shopping list. It contains items like milk, bread, and eggs. "
                  "Seems like a typical grocery list.")
        else:
            print("It was on the fridge. I need to go to the fridge first")

    def examine_folded_note(self):
        if self.next_to_object == Object.FRIDGE:
            self.play_sound('sounds/papier - wszystkie interakcje z papierem(pytanie xd).mp3')
            print("I am unfolding the note. Oh! It looks like another note from my notebook!\n"
                  "The note says: 'I cannot believe it! How could he do this to me? I trusted him with everything. "
                  "He was so important to me, but now... The pain is unbearable.'")
            self.memory[Memory.FOUND_KITCHEN_NOTE] = True
        else:
            print("It was on the fridge. I need to go to the fridge first")

    def examine_knife(self):
        if self.next_to_object == Object.TABLE:
            self.play_sound('sounds/VR_noz.wav')
            print("This knife is really large. It is covered in blood. The blood does not seem to be from the meat. "
                  "It looks weird...")
            self.memory[Memory.FOUND_KNIFE] = True
        else:
            print("It was on the table. I need to go to the table first")

    def examine_letter(self):
        if self.next_to_object == Object.BESIDE_TABLE:
            print('"Dear Vanessa, last meeting was everything what we needed.\n'
                  'Can\'t wait to see you tonight and arrange everything.\n'
                  'Charlie"\nWhat is this letter? What does it mean?!')
            self.memory[Memory.FOUND_BEDROOM_LETTER] = True
        else:
            print("It was on the bedside table. I need to go to the bedside table first")

    def examine_phone(self):
        if self.next_to_object == Object.PERSON:
            self.play_sound('sounds/VR_telefon.wav')
            print("Yes, they had some secret meetings... They don't talk about their relationship though...\n"
                  "They're talking about ME! But not in a bad way, they are worried...\n"
                  "Worried about me? Vanessa writes that I'm not in the best mental place.\n"
                  "That I am impulsive, under a lot of stress, that I started seeing things...\n"
                  "Suddenly I hear another voice... no emotions in it, almost as it wasn't exactly human one...")
            self.memory[Memory.FOUND_BODY] = True
            print('"Deep down you knew we didn\'t do it...\nYou knew and you still did it...\n'
                  'Even though I showed our texts...\nYou didn\'t listen..."')
            print('You can use look_up command to see what was the source of the sound')
        else:
            print("I need to go to the person first")

    def look_up(self):
        if self.next_to_object == Object.PERSON and self.memory[Memory.FOUND_BODY]:
            print("Frightened I look up from the phone... And I look right into eyes... Charlie's eyes...\n"
                  "But they're empty now... They always had a spark of joy in them...\n"
                  "Then Charlie opens his mouth once again and speaks with this unreal, dead voice...\n"
                  "'You remember it now, right? How you took knife from kitchen... chased me here - to the attic...'\n"
                  "I tell him to stop... Just don't finish, please... I BEG YOU! But he does finish...\n"
                  "And all my fears become reality... My whole life shatters...\n"
                  "I see those terrifying scenes happening just before my eyes... My hands covered in blood...\n"
                  "Just like they are now... I have to get out of here...")
            self.finale()

    def save_charlie(self):
        if self.current_room == Room.ATTIC and self.next_to_object == Object.FABRIC:
            print("I'm pushing fabric against wounds, but blood just keeps coming...\n"
                  "Now my hands are covered in scarlet fluid and I can't help but sob...\n"
                  "My dear friend... what happened? Who could have done this... That's why Vanessa is crying...\n"
                  "Right, but Charlie and Vanessa... Now it's all coming together... My notes and their letters...\n"
                  "I feel extreme anger, I almost can't think clearly... I know who did this.\n"
                  "But it was fair punishment for betraying me... HE DESERVED THIS!\n"
                  "I see something glowing in Charlie's hand... What is it?")
            self.rooms[Room.ATTIC].append(Object.PHONE)
        else:
            print("Unknown command.")

    def finale(self):
        if self.current_room == Room.ATTIC:
            self.current_room = Room.HALL
            print("I pass through what's left from attic door...")
            self.play_sound('sounds/VR_kobiecy placz i belkot .wav')
            print('"Why did you do it..." I hear Vanessa, my lovely wife still crying in the bedroom...')
            print("I'm sorry! I'M SO SORRY! It wasn't meant to be like this...")
            print("I feel like I'm suffocating in this damn house!")
            print("I managed to run to the hall, I see the front door, I can get out of this madness")


if __name__ == '__main__':
    # Initialize and start the game
    DEBUG_MODE = False
    game = AdventureGame()
    game.start()
