class AdventureGame:
    def __init__(self):
        self.current_room = 'hall'
        self.next_to_object = 'dresser'
        self.rooms = {
            'hall': ['front_door', 'dresser', 'wardrobe', 'umbrella', 'plant', 'painting', 'door'],
            'office': ['desk', 'chair', 'computer', 'bookshelf'],
            'kitchen': ['table', 'fridge', 'window', 'attic_door'],
            'bedroom': ['bed', 'bedside_table', 'closet', 'wife'],
            'garage': ['car', 'tool_shelf', 'garage_door'],
            'attic': ['person', 'attic_door', 'fabric']
        }
        self.holding = None
        self.memory = {
            'remember_names': ('wife', 'guy'),
            'remember_stress': False,
            'found_note_knife': 0,
            'found_letter_wife': 0,
            'found_crowbar': False,
            'found_body': False
        }

    def start(self):
        self.introduction()
        self.command_loop()

    def introduction(self):
        print("I just rushed into the hallway of my house, feeling scared and confused.")
        print("Suddenly, it hit me — I can't remember why I was running or why I'm so shaky.")
        print("Maybe if I go back to the front door, I'll figure out what spooked me.")
        self.help()

    def help(self):
        print("\nAvailable commands: 'look', 'go_to <object>', 'examine <object>', 'help'")

    def command_loop(self):
        while True:
            command = input("> ").strip().lower().split(" ")
            match command:
                case ['look']:
                    self.look()
                case ['go_to', obj]:
                    self.go_to(obj)
                case ['examine', obj]:
                    self.examine(obj)
                case ['save_charlie']:
                    self.save_charlie()
                case ['try_open_attic_door']:
                    self.try_open_attic_door()
                case ['look_up']:
                    self.look_up()
                case ['help']:
                    self.help()
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

    def go_to(self, obj):
        if obj in self.rooms[self.current_room]:
            self.next_to_object = obj
            self.interact_with(obj)
        else:
            print("This object is not nearby.")

    def interact_with(self, object):
        interactions = {
            'front_door': self.interact_front_door,
            'plant': lambda: self.find_note("Oh! There's a note behind the plant! 'Got home tired, found a candlelit dinner in the backyard, thanks to my wife. Made my day!'"),
            'painting': lambda: self.find_note("Oh! There's a note below the painting! 'Today, my wife surprised me with breakfast in bed. Waking up to the smell of freshly brewed coffee and the sight of my favorite pancakes made me feel incredibly loved and appreciated.'"),
            'dresser': self.find_key,
            'umbrella': lambda: print("I found an umbrella. It's kinda useless, cause I'm inside the building."),
            'wardrobe': lambda: print("There is a big old wardrobe here. Inside I can see coats that belong to a female."),
            'door': self.try_to_open_door,
            'desk': lambda: print("Oh! There's another note on the desk! 'Me and my best friend had a great time in the park, laughing and snacking on a cozy blanket. It's moments like these that make life awesome.'"),
            'computer': self.explore_computer,
            'chair': lambda: print("There is a chair here. It looks like someone was sitting here recently."),
            'bookshelf': self.bookshelf_interaction,
            'table': self.table_interaction,
            'fridge': self.fridge_interaction,
            'window': lambda: print("This is kitchen window. It's pretty dark outside. It's hard to see what's out there."),
            'attic_door': self.attic_door_interaction,
            'bedside_table': self.bedside_table_interaction,
            'closet': lambda: print("I approach the closet. It is slightly open. Inside I see some clothes and shoes. But I don't plan to dressing up so... no use"),
            'wife': self.wife_interaction,
            'car': lambda: print("Oh it's beautiful! 1964 Pontiac GTO... I spent hours repairing it! We had so many nice trips with Vanessa in this car. And with Charlie... I must find a tool to open that attic though, let's focus on that now."),
            'tool_shelf': self.tool_shelf_interaction,
            'garage_door': self.garage_door_interaction,
            'person': self.person_interaction,
            'fabric': lambda: print("This should work! Write save_charlie to use fabric to stop the bleeding.")
        }

        if action := interactions.get(object):
            action()
        else:
            print(f"Nothing special about the {object}.")

    def find_note(self, message):
        print(message)

    def find_key(self):
        print("I found a key in the drawer. I wonder what it opens.")
        self.holding = 'office_key'

    def interact_front_door(self):
        if not self.memory['found_body']:
            print("Oh no! I'm trying to open the front door, but it seems like it's closed. Maybe I'll try to look around and see if I can find some clues.")
        else:
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

    def try_to_open_door(self):
        if self.holding == 'office_key':
            print("I opened the door with the key and went inside the office.")
            self.current_room = 'office'
            self.holding = None
        else:
            print("This door is closed. Maybe I can find some key that opens it.")

    def explore_computer(self):
        print("Exploring the computer...")
        if not self.memory['remember_names'][0] == 'Vanessa':
            print("I found a folder named 'Venice_2019'.")
            print("In another folder named 'My beautiful wife' I found photos of some female.")
            print("Oh god! I found a picture from the wedding! The guy she has married is me! This is my wife!")
            print("I've just recalled her name! It's Vanessa! And the guy on previous photos is my best friend, Charlie!")
            self.memory['remember_names'] = ('Vanessa', 'Charlie')
            self.lock_squeaks()
        else:
            print("There are so many beautiful photos of my wife, Vanessa on this computer. I love her so much.")
            print("Oh, here is a photo of me and Charlie from our childhood. He is such a good friend of mine.")

    def lock_squeaks(self):
        if self.memory['remember_stress'] and self.memory['remember_names'][0] == 'Vanessa':
            print("I heard a squeak from the lock. Oh, I think this sound came from the kitchen! I can go there now!")
            self.rooms['office'].append('kitchen_door')

    def bookshelf_interaction(self):
        print("There is a bookshelf here. There's another note here!")
        print("I have so much work to do! I can't find time for my wife... I am so stressed out that sometimes I can't control my emotions...")
        self.memory['remember_stress'] = True
        self.lock_squeaks()

    def table_interaction(self):
        print("There is a table here. Looks like someone was preparing meat for dinner. There is a knife lying next to it.")
        self.rooms['kitchen'].append('knife')

    def fridge_interaction(self):
        print("This fridge is covered with colorful magnets and written notes. And there is a calendar hanging on the fridge.")
        self.rooms['kitchen'].extend(['calendar', 'shopping_list', 'folded_note'])

    def attic_door_interaction(self):
        print("There are blood stains on the door and the knob. And streaks of blood leading up to the entrance. I need to go to the attic to check what happened.")
        print("You can write try_open_attic_door()")

    def bedside_table_interaction(self):
        print("I am next to the bedside_table. There is a lamp on it. And there seems to be a folded note under the lamp. Oh it is some kind of letter.")
        self.rooms['bedroom'].append('letter')

    def wife_interaction(self):
        print("Vanessa? Vanessa, what is going on?")
        print("She is sitting on the bed, crying. I try to speak to her, but she does not respond. It seems like she cannot see me. What is happening?")
        self.memory['found_letter_wife'] += 1

    def tool_shelf_interaction(self):
        print("There are piles of screws and scraps of papers. Crap, I am not a tidy person, I hope I will find something though. Oh yes! Between hammers I found a crowbar! That should do it! Now I can use this to open the attic door...")
        self.memory['found_crowbar'] = True

    def garage_door_interaction(self):
        if self.memory['found_crowbar']:
            print("Let's go to that attic now...")
            self.current_room = 'kitchen'
        else:
            print("I have to find something to open that attic door first...")

    def person_interaction(self):
        print("No, no, NO! It's Charlie! He's all covered in blood... He's got two... no, three wounds in his chest... Blood is oozing from cuts, contrasting with his pale skin... I have to find something to stop the bleeding!")
        self.rooms['attic'].append('fabric')

    def try_open_attic_door(self):
        if self.memory['found_crowbar']:
            print("It was a struggle but I managed to open it. I can enter the attic now...")
            self.current_room = 'attic'
        else:
            print("I try to open the door, but it is locked. The door seems to be jammed. I need something to pry it open. Maybe in the garage I will find something to open it")

    def examine(self, obj):
        examinations = {
            'calendar': self.examine_calendar,
            'shopping_list': self.examine_shopping_list,
            'folded_note': self.examine_folded_note,
            'knife': self.examine_knife,
            'letter': self.examine_letter,
            'wife': lambda: print("Vanessa! Are you hearing me?"),
            'car': lambda: print("The car is locked, I must have left the keys somewhere. It's not important now, let's find a way to open that attic."),
            'tool_shelf': lambda: print("There are piles of screws and scraps of papers. Crap, I am not a tidy person, I hope I will find something though. Oh yes! Between hammers I found a crowbar! That should do it! Now I can use this to open the attic door..."),
            'person': lambda: print("He's holding a phone... I remember now - he tried showing me something... Probably evidence of their betrayal... Yes, let's see their texts...") or self.rooms['attic'].append('phone'),
            'phone': self.examine_phone
        }
        action = examinations.get(obj)
        if action:
            action()
        else:
            print(f"I think it is just the {obj}. Nothing more to see here")

    def examine_calendar(self):
        if self.next_to_object == 'fridge':
            print("It is a calendar with a fun photo of a dog. Today's date is circled in red with Charlie's name. Maybe he is coming here today. I would love to see my dear friend")
        else:
            print("It was on the fridge. I need to go to the fridge first")

    def examine_shopping_list(self):
        if self.next_to_object == 'fridge':
            print("It is a shopping list. It contains items like milk, bread, and eggs. Seems like a typical grocery list.")
        else:
            print("It was on the fridge. I need to go to the fridge first")

    def examine_folded_note(self):
        if self.next_to_object == 'fridge':
            print("I am unfolding the note. Oh! It looks like another note from my notebook! The note says: 'I cannot believe it! How could he do this to me? I trusted him with everything. He was so important to me, but now... The pain is unbearable.'")
            self.memory['found_note_knife'] += 1
        else:
            print("It was on the fridge. I need to go to the fridge first")

    def examine_knife(self):
        if self.next_to_object == 'table':
            print("This knife is really large. It is covered in blood. The blood does not seem to be from the meat. It looks weird...")
            self.memory['found_note_knife'] += 1
        else:
            print("It was on the table. I need to go to the table first")

    def examine_letter(self):
        if self.next_to_object == 'bedside_table':
            print('"Dear Vanessa, last meeting was everything what we needed. Can\'t wait to see you tonight and arrange everything. Charlie" What is this letter? What it means?!')
            self.memory['found_letter_wife'] += 1
        else:
            print("It was on the bedside_table. I need to go to the bedside_table first")

    def examine_phone(self):
        if self.next_to_object == 'person':
            self.memory['found_body'] = True
            print("Yes, they had some secret meetings... They don't talk about their relationship though... They're talking about ME! But not in a bad way, they are worried... Worried about me? Vanessa writes that I'm not in the best mental place. That I am impulsive, under a lot of stress, that I started seeing things... Suddenly I hear another voice... no emotions in it, almost as it wasn't exactly human one...")
            self.charlie_talks()
        else:
            print("I need to go to the person first")

    def charlie_talks(self):
        print('"Deep down you knew we didn\'t do it... You knew and you still did it... Even though I showed our texts... You didn\'t listen..." write look_up. to see who spoke')

    def look_up(self):
        if self.next_to_object == 'person' and self.memory['found_body']:
            print("Frightened I look up from the phone... And I look right into eyes... Charlie's eyes... But they're empty now... They always had a spark of joy in them... Then Charlie opens his mouth once again and speaks with this unreal, dead voice... 'You remember it now, right? How you took knife from kitchen... chased me here - to the attic...' I tell him to stop... Just don't finish, please... I BEG YOU! But he does finish... And all my fears become reality... My whole life shatters... I see those terrifying scenes happening just before my eyes... My hands covered in blood... Just like they are now... I have to get out of here...")

    def save_charlie(self):
        if self.current_room == 'attic' and self.next_to_object == 'fabric':
            print("I'm pushing fabric against wounds, but blood just keeps coming... Now my hands are covered in scarlet fluid and I can't help but sob... My dear friend... what happened? Who could have done this... That's why Vanessa is crying... Right, but Charlie and Vanessa... Now it's all coming together... My notes and their letters... I feel extreme anger, I almost can't think clearly... I know who did this. But it was fair punishment for betraying me... HE DESERVED THIS! I see something glowing in Charlie's hand... What is it?")
            self.finale()
        else:
            print("Unknown command.")

    def finale(self):
        if self.current_room == 'attic':
            self.current_room = 'hall'
            print("I pass through what's left from attic door...")
            print('"Why did you do it..." I hear Vanessa, my lovely wife still crying in the bedroom...')
            print("I'm sorry! I'M SO SORRY! It wasn't meant to be like this...")
            print("I feel like I'm suffocating in this damn house!")
            print("I managed to run to the hall, I see the front door, I can get out of this madness")


if __name__ == '__main__':
    # Initialize and start the game
    game = AdventureGame()
    game.start()
