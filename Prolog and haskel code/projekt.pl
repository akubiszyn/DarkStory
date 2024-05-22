:- dynamic i_am_at/1, at/2, holding/1, remember_names/2, remember_stress/1, found_note_knife/1, found_letter_wife/1, found_crowbar/1, found_body/1.
:- retractall(at(_, _)), retractall(i_am_at(_)), retractall(alive(_)), retractall(i_am_next_to(_)), retractall(holding(_)).


i_am_at(hall).
i_am_next_to(dresser).
remember_names(wife, guy).
remember_stress(0).
found_note_knife(0).
found_letter_wife(0).
found_crowbar(0).
found_body(0).


/* These are predicates that describe a hall. */

at(front_door, hall).
at(dresser, hall).
at(wardrobe, hall).
at(umbrella, hall).
at(plant, hall).
at(painting, hall).
at(door, hall).

at(desk, office).
at(chair, office).
at(computer, office).
at(bookshelf, office).

/* KITCHEN */

at(table, kitchen).
at(fridge, kitchen).
at(window, kitchen).
at(attic_door, kitchen).


/* BEDROOM */
at(bed, bedroom).
at(bedside_table, bedroom).
at(closet, bedroom).
at(wife, bedroom).

/* GARAGE */
at(car, garage).
at(tool_shelf, garage).
at(garage_door, garage).

/* ATTIC */
at(person, attic).
at(attic_door, attic).

start :-
    introduction.


look :-
    i_am_at(Place),
    describe(Place),
    describe_object_next_to_you(_),
    nl,
    notice_objects_at(Place),
    nl. 

/* These rules set up a loop to mention all the objects
   in your vicinity. */

describe_object_next_to_you(Object) :-
    i_am_next_to(Object),
    write('There is a '), write(Object), write(' next to you.'), nl,
    fail.

describe_object_next_to_you(_).

notice_objects_at(Place) :-
    at(X, Place),
    write('There is a '), write(X), write(' here.'), nl,
    fail.

notice_objects_at(_).

describe(Place) :- write('You are at the '), write(Place), write('.'), nl.
describe(_).


goTo(Object) :-
    i_am_at(Place),
    \+ at(Object, Place),
    write('This object is not nearby.'), nl.

goTo(front_door) :-
    i_am_at(hall),
    found_body(0),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(front_door)),
    write('Oh no! I''m trying to open the front door, but it seems like it''s closed.'), nl,
    write('Maybe I''ll try to look around and see if I can find some clues.'), nl.

goTo(front_door) :-
    i_am_at(hall),
    found_body(1),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(front_door)),
    write('It\'s open now! I run through them...'), nl,
    write('I don\'t even look around, I just wanna run as far as possible...'), nl,
    write('I just don\'t want to hear this crying anymore...'), nl,
    write('Suddenly my boots step on something hard, like wood...'), nl,
    write('I hear door closing behind me and I now know what will happen...'), nl,
    write('It will happen again... As it did so many times before...'),
    assert(i_am_next_to(dresser)),
    assert(remember_names(wife, guy)),
    assert(remember_stress(0)),
    assert(found_note_knife(0)),
    assert(found_letter_wife(0)),
    assert(found_crowbar(0)),
    assert(found_body(0)), nl, nl,
    introduction.


goTo(plant) :-
    i_am_at(hall),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(plant)),
    write('Oh! There''s a note behind the plant! It looks like sheet of paper from some notebook. Let''s see what is written on this note.'), nl,
    write('"Got home tired, found a candlelit dinner in the backyard, thanks to my wife. Made my day!".'), nl.

goTo(painting) :-
    i_am_at(hall),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(painting)),
    write('Oh! There''s a note below the painting! It looks like sheet of paper from some notebook. Let''s see what is written on this note.'), nl,
    write('"Today, my wife surprised me with breakfast in bed.".'), nl,
    write('"Waking up to the smell of freshly brewed coffee and the sight of my favorite pancakes made me feel incredibly loved and appreciated.".'), nl. 

goTo(dresser) :-
    i_am_at(hall),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(dresser)),
    write('I found a key in the drawer. I wonder what it opens.'), nl,
    assert(holding(office_key)).       

goTo(umbrella) :-
    i_am_at(hall),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(umbrella)),
    write('I found an umbrella. It''s kinda useless, cause I''m inside the building.'), nl.

goTo(wardrobe) :-
    i_am_at(hall),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(wardrobe)),
    write('There is a big old wardrobe here. Inside I can see coats that belong to a female.'), nl.

goTo(door) :-
    i_am_at(hall),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(door)),
    holding(Object),
    write('This door is closed. Maybe I can find some key that opens it.'), nl,
    try_to_open_door(Object).

goTo(desk) :-
    i_am_at(office),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(desk)),
    write('Oh! There''s another note on the desk! '), nl,
    write('"Me and my best friend had a great time in the park, laughing and snacking on a cozy blanket. It''s moments like these that make life awesome."".'), nl,
    lock_squeaks.


goTo(computer) :-
    i_am_at(office),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(computer)),
    write('Someone left their computer without logging off, let''s see if I can find some things that that might spark my memories'), nl, nl,
    write('Write a command: "explore_computer." in order to search for some clues. ."".'), nl,
    lock_squeaks.

goTo(chair) :-
    i_am_at(office),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(chair)),
    write('There is a chair here. It looks like someone was sitting here recently.'), nl,
    lock_squeaks.

goTo(bookshelf) :-  
    i_am_at(office),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(bookshelf)),
    write('There is a bookshelf here. There''s anoter note here!'), nl,
    write('"I have so much work to do! I can''t find time for my wife... I am so stressed out that sometimes I can''t contol my emotions...".'), nl,
    retract(remember_stress(0)),
    assert(remember_stress(1)),
    lock_squeaks.

/* KITCHEN */
/* założenie: musi poznać imiona zanim wejdzie do kuchni */

goTo(kitchen) :-  
    retract(i_am_at(office)),
    assert(i_am_at(kitchen)),
    write('I entered the kitchen. It looks tidy and cozy. Maybe Vanessa is somewhere here..'), nl,
    write('I will look around to search something'), nl.


goTo(fridge) :-
    i_am_at(kitchen),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(fridge)),
    write('This fridge is covered with colorful magnets and written notes.'), nl,
    write('And there is a calendar hanging on the fridge.'), nl,
    assert(at(calendar, kitchen)),
    assert(at(shopping_list, kitchen)),
    assert(at(folded_note, kitchen)).

goTo(window) :-
    i_am_at(kitchen),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(window)),
    write('This is kitchen window.'), nl,
    write('It\'s pretty dark outside.'), nl,
    write('It hard to see what\'s out there.'), nl.

goTo(table) :-
    i_am_at(kitchen),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(table)),
    write('There is a table here. Looks like someone was preparing meat for dinner. '), nl,
    write('There is a knife lying next to it'), nl,
    assert(at(knife, kitchen)).

goTo(attic_door) :-
    i_am_at(kitchen),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(attic_door)),
    write('There are blood stains on the door and the knob.'), nl,
    write('And streaks of blood leading up to the entrance.'), nl,
    write('I need to go to the attic to check what happened'), nl,
    write('You can write try_open_attic_door()'), nl.

goTo(calendar) :-
    i_am_at(kitchen),
    write('It was on the fridge. I need to go to the fridge first and then examine calendar'), nl.

goTo(shopping_list) :-
    i_am_at(kitchen),
    write('It was on the fridge. I need to go to the fridge first and then examine shopping_list'), nl.

goTo(folded_note) :-
    i_am_at(kitchen),
    write('It was on the fridge. I need to go to the fridge first and then examine folded_note'), nl.

goTo(knife) :-
    i_am_at(kitchen),
    write('It was on the table. I need to go to the table first and then examine knife'), nl.


/* BEDROOM */

goTo(bedroom) :-
    found_note_knife(2),
    retract(i_am_at(kitchen)),
    assert(i_am_at(bedroom)),
    write('I entered the bedroom.'), nl,
    write('Oh Vanessa is here sitting on the bed'), nl,
    write('Oh no she\'s crying.'), nl.

goTo(bedroom) :-
    \+ found_note_knife(2),
    write('I think I need to find more clues about what happened before I go to the bedroom'), nl.

goTo(closet) :-
    i_am_at(bedroom),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(closet)),
    write('I approach the closet. It is slightly open.'), nl,
    write('Inside I see some clothes and shoes.'), nl,
    write('But I don\'t plan to dressing up so... no use'), nl.

goTo(bedside_table) :-
    i_am_at(bedroom),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(bedside_table)),
    write('I am next to the bedside_table. There is a lamp on it.'), nl,
    write('And there seems to be a folded note under the lamp.'), nl,
    write('Oh it is some kind of letter'), nl,
    assert(at(letter, bedroom)).

goTo(wife) :-
    i_am_at(bedroom),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(wife)),
    write('"Vanessa? Vanessa, what is going on?"'), nl,
    write('She is sitting on the bed, crying.'), nl,
    write('I try to speak to her, but she does not respond.'), nl,
    write('It seems like she cannot see me. What is happening?'), nl,
    retract(found_letter_wife(Count)),
    NewCount is Count + 1,
    assert(found_letter_wife(NewCount)).

goTo(bed) :-
    i_am_at(bedroom),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(wife)),
    write('Is the bed on which Vanessa is sitting'), nl,
    write('She is still crying'), nl,
    write('"Why did you do it?? Oh whyy"'), nl,
    write('I want to help her, but she is not hearing me'), nl,
    write('Maybe in garage I will something to break door and go to the attic'), nl,
    retract(found_letter_wife(Count)),
    NewCount is Count + 1,
    assert(found_letter_wife(NewCount)),
    assert(at(garage, bedroom)).

goTo(garage) :-
    \+ found_letter_wife(3),
    i_am_at(bedroom),
    write('I need to find out more why Vanessa is crying before I will go to garage'), nl.

goTo(garage) :-
    found_letter_wife(3),
    i_am_at(bedroom),
    retract(i_am_at(bedroom)),
    assert(i_am_at(garage)),
    write('I entered the garage. It\'s a bit gloomy in here'), nl,
    write('I have to find something to open that attic though'), nl.

/* GARAGE */

goTo(car) :-
    i_am_at(garage),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(car)),
    write('Oh it\'s beautiful! 1964 Pontiac GTO...'), nl,
    write('I spent hours repering it! We had so many nice trips with Vanessa in this car.'), nl,
    write('And with Charlie...'), nl,
    write('I must find a tool to open that attic though, let\'s focus on that now'), nl.

goTo(tool_shelf) :-
    i_am_at(garage),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(tool_shelf)),
    write('There are piles of screws and scraps of papers...'), nl,
    write('Crap, I am not a tidy person, I hope I will find something though'), nl.

goTo(garage_door) :-
    i_am_at(garage),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(garage_door)),
    found_crowbar(0),
    write('I have to find something to open that attic door first...'), nl.

goTo(garage_door) :-
    i_am_at(garage),
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(garage_door)),
    found_crowbar(1),
    write('Let\'s go to that attic now...'), nl,
    retract(i_am_at(garage)),
    assert(i_am_at(kitchen)).

/* ATTIC */
goTo(attic) :-
    retract(i_am_next_to(_)),
    assert(i_am_next_to(attic_door)),
    retract(i_am_at(kitchen)),
    assert(i_am_at(attic)),
    write('Okay, I am finally in the attic, let\'s find out what\'s going on with those weird blood stains...'), nl.

goTo(attic_door) :-
    i_am_at(attic),
    retract(i_am_next_to(_)),
    assert(i_am_next_to(attic_door)),
    found_body(0),
    write('Why there is a body here? Let\'s just check it real quick...'), nl.

goTo(attic_door) :-
    i_am_at(attic),
    retract(i_am_next_to(_)),
    assert(i_am_next_to(attic_door)),
    found_body(1),
    write('Oh my God! I have to get out of here...'), nl,
    write('If I stay here a second longer I will go insane!'), nl,
    finale.

goTo(person) :-
    retract(i_am_next_to(_)),
    assert(i_am_next_to(person)),
    write('No, no, NO! It\'s Charlie! He\'s all covered in blood...'), nl,
    write('He\'s got two... no, three wounds in his chest...'), nl,
    write('Blood is oozing from cuts, contrasting with his pale skin...'), nl,
    write('I have to find something to stop the bleeding!'), nl,
    assert(at(fabric, attic)).

goTo(fabric) :-
    i_am_next_to(OldObject),
    retract(i_am_next_to(OldObject)),
    assert(i_am_next_to(fabric)),
    write('This should work!'), nl,
    write('Write save_charlie to use fabric to stop the bleeding.'), nl.

save_charlie :-
    retract(i_am_next_to(_)),
    assert(i_am_next_to(person)),
    write('I\'m pushing fabric against wounds, but blood just keeps coming...'), nl,
    write('Now my hands are covered in scarlet fluid and I can\'t help but sob...'), nl,
    write('My dear friend... what happened? Who could have done this...'), nl,
    write('That\'s why Vanessa is crying... Right, but Charlie and Vanessa...'), nl,
    write('Now it\'s all coming together... My notes and theirs letters...'), nl, nl,
    write('I feel extreme anger, I almost can\'t think clearly...'), nl,
    write('I know who did this. But it was fair punishment for betraying me... HE DESERVED THIS!'), nl,
    write('I see something glowing in Charlie\'s hand... What is it?'), nl.

finale :-
    retract(i_am_at(attic)),
    assert(i_am_at(hall)),
    found_body(1),
    write('I pass through what\'s left from attic door...'), nl,
    write('"Why did you do it..." I hear Vanessa, my lovely wife still crying in the bedroom...'), nl,
    write('I\'m sorry! I\'M SO SORRY! It wasn\'t meant to be like this...'), nl,
    write('I feel like I\'m suffocating in this damn house!'), nl,
    write('I managed to run to the hall, I see the front door, I can get out of this madness'), nl.

lock_squeaks :-
    i_am_at(office),
    remember_stress(0).

lock_squeaks :-
    i_am_at(office),
    remember_names(wife, guy).

lock_squeaks :-
    i_am_at(office),
    remember_stress(1),
    remember_names(vanessa, charlie),
    write('I heard a squeak from the lock. Oh, I think this sound came from the kitchen! I can go there now!'), nl,
    write('You can go now to kitchen by typing: "goTo(kitchen)."'), nl,
    assert(at(kitchen, office)).



try_to_open_door(office_key) :-
    holding(office_key),
    write('I opened the door and went inside.'), nl,
    retract(i_am_at(hall)),
    assert(i_am_at(office)),
    retract(holding(office_key)),
    write('I think it''s the office! Let'' look around and see what can I find here.'), nl.

try_to_open_door(_) :-
    \+ holding(office_key),
    write('I don''t have the key to open this door.'), nl.

explore_computer :-
    i_am_next_to(computer),
    remember_names(wife, guy),
    write('I found a folder named "Venice_2019".'), nl,
    write('I opened the folder and found pictures from the trip that apparently me and some guy went on together.'), nl,
    write('In another folder named "My beautiful wife" I found photos of a some female.'), nl,
    write('Oh god! I found a picture from the wedding! The guy that she has married is me! This is my wife!'), nl,
    write('I''ve just recalled her name! It''s Vanessa! And the guy on previous photos is my best friend, Charlie!'), nl,
    write('And this is my house! And notes from MY notebook! I need to know what happened!'), nl,
    retract(remember_names(wife, guy)),
    assert(remember_names(vanessa, charlie)),
    lock_squeaks.

explore_computer :-
    i_am_next_to(computer),
    remember_names(vanessa, charlie),
    write('There are so many beaufiful photos of my wife, Vanessa on this computer. I love her so much.'), nl,
    write('Oh, here is a photo of me and Charlie from our childhood. He is such a good friend of mine.'), nl.

introduction :-
    write('I just rushed into the hallway of my house, feeling scared and confused.'), nl,
    write(' Suddenly, it hit me — I can\'t remember why I was running or why I\'m so shaky.'), nl,
    write(' Maybe if I go back to the front door, I\'ll figure out what spooked me.'), nl, nl,
    write('You can type the following commands:'), nl,
    write('look.                -- to look around you.'), nl,
    write('goTo(Object).        -- to go the object.'), nl,
    write('examine(Object).     -- to look closer at the object.'), nl.

/*KITCHEN*/

examine(calendar) :-
    i_am_at(kitchen),
    i_am_next_to(fridge),
    write('It is calendar with fun photo of dog.'), nl,
    write('Today\'s date is circled in red with Charlie\'s name'), nl,
    write('Maybe he is coming here today. I would love to see my dear friend'), nl.

examine(calendar) :-
    i_am_at(kitchen),
    \+ i_am_next_to(fridge),
    write('It was on the fridge. I need to go to the fridge first'), nl.

examine(shopping_list) :-
    i_am_at(kitchen),
    i_am_next_to(fridge),
    write('It is shopping list.'), nl,
    write('It contains items like milk, bread, and eggs.'), nl,
    write('Seems like a typical grocery list.'), nl.

examine(shopping_list) :-
    i_am_at(kitchen),
    \+ i_am_next_to(fridge),
    write('It was on the fridge. I need to go to the fridge first'), nl.


examine(folded_note) :-
    i_am_at(kitchen),
    i_am_next_to(fridge),
    write('I am unfolding the note.'), nl,
    write('Oh! It looks like another note from my notebook!'), nl,
    write('The note says:'), nl,
    write('"I cannot believe it! How could he do this to me? I trusted him with everything.'), nl,
    write('He was so important to me, but now... The pain is unbearable."'), nl,
    retract(found_note_knife(Count)),
    NewCount is Count + 1,
    assert(found_note_knife(NewCount)).

examine(folded_note) :-
    i_am_at(kitchen),
    \+ i_am_next_to(fridge),
    write('It was on the fridge. I need to go to the fridge first'), nl.


examine(knife) :-
    i_am_at(kitchen),
    i_am_next_to(table),
    write('This knife is really large.'), nl,
    write('It is covered in blood.'), nl,
    write('The blood does not seem to be from the meat.'), nl,
    write('It looks weird...'), nl,
    retract(found_note_knife(Count)),
    NewCount is Count + 1,
    assert(found_note_knife(NewCount)).

examine(knife) :-
    i_am_at(kitchen),
    \+ i_am_next_to(table),
    write('It was on the table. I need to go to the table first'), nl.

/* BEDROOM */
examine(letter) :-
    i_am_at(bedroom),
    i_am_next_to(bedside_table),
    write('"Dear Vanessa'), nl,
    write('last meeting was everything what we needed.'), nl,
    write('Can''t wait to see you tonight and arrange everything'), nl,
    write('Charlie"'), nl,
    write('What is this letter? What it is means?!'), nl,
    retract(found_letter_wife(Count)),
    NewCount is Count + 1,
    assert(found_letter_wife(NewCount)).

examine(letter) :-
        i_am_at(bedroom),
        \+ i_am_next_to(bedside_table),
        write('It was on the bedside_table. I need to go to the bedside_table first'), nl.

examine(wife) :-
        i_am_at(bedroom),
        write('"Vanessa! Are you hearing me?'), nl.

/* GARAGE */

examine(car) :-
    i_am_at(garage),
    i_am_next_to(car),
    write('The car is locked, I must have left the keys somewhere'), nl,
    write('It\'s not important now, let\'s find a way to open that attic'), nl.

examine(tool_shelf) :-
    i_am_at(garage),
    i_am_next_to(tool_shelf),
    write('Oh yes! Between hammers I found crowbar!'), nl,
    write('That should do it! Now I can use this to open attic door...'), nl,
    retract(found_crowbar(0)),
    assert(found_crowbar(1)).

/* ATTIC */
examine(person) :-
    i_am_at(attic),
    i_am_next_to(person),
    write('He\'s holding a phone... I remember now - he tried showing me something...'), nl,
    write('Probably evidence of their betrayal... Yes, let\'s see their texts...'), nl,
    assert(at(phone, attic)).

examine(phone) :-
    i_am_at(attic),
    i_am_next_to(person),
    write('Yes, they had some secret meetings... They don\'t talk about their relationship though...'), nl,
    write('They\'re talking about ME! But not in a bad way, they are worried...'), nl,
    write('Worried about me? Vanessa writes that I\'m not in the best mental place'), nl,
    write('That I am impulsive, under a lot of stress, that I started seeing things...'), nl,
    write('Suddenly I hear another voice... no emotions in it, almost as it wasn\'t exactly human one...'), nl,
    retract(found_body(0)),
    assert(found_body(1)),
    charlie_talks.

examine(Object) :-
    i_am_next_to(Object),
    write('I think it is just the '), write(Object), nl,
    write('Nothing more to see here'), nl.

charlie_talks :-
    i_am_at(attic),
    i_am_next_to(person),
    found_body(1),
    write('"Deep down you knew we didn\'t do it... You knew and you still did it...'), nl,
    write('Even though I showed our texts... You didn\'t listen..."'), nl,
    write('write look_up. to see who spoke'), nl.

look_up :-
    i_am_at(attic),
    i_am_next_to(person),
    found_body(1),
    write('Frightened I look up from the phone... And I look right into eyes...'), nl,
    write('Charlie\'s eyes... But they\'re empty now... They always had a spark of joy in them...'), nl,
    write('Then Charlie openes his mouth once again and speaks with this unreal, dead voice...'), nl,
    write('"You remember it now, right? How you took knife from kitchen... chased me here - to the attic..."'), nl,
    write('I tell him to stop... Just don\'t finish, please... I BEG YOU!'), nl,
    write('But he does finish... And all my fears become reality... My whole life shatters...'), nl,
    write('I see those terrifying scenes happening just before my eyes...'), nl,
    write('My hands covered in blood... Just like they are now...'), nl,
    write('I have to get out of here...'), nl.

try_open_attic_door :-
    i_am_at(kitchen),
    i_am_next_to(attic_door),
    found_crowbar(1),
    write('It was a struggle but I managed to open it'), nl,
    write('I can enter the attic now...'), nl,
    assert(at(attic, kitchen)).

try_open_attic_door :-
    i_am_at(kitchen),
    i_am_next_to(attic_door),
    write('I try to open the door, but it is locked.'), nl,
    write('The door seems to be jammed. I need something to pry it open.'), nl,
    write('Maybe in bedroom I will find something to open it'), nl,
    assert(at(bedroom, kitchen)).
