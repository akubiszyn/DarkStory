import System.IO
import Data.List (intercalate, elem)
import System.Random


introductionText = [
    "",
    "I just rushed into the hallway of my house, ",
    "feeling scared and confused.",
    "Suddenly, it hit me — I can't remember ",
    "why I was running or why I'm so shaky.",
    "Maybe if I go back to the front door, ",
    "I'll figure out what spooked me.",
    ""
    ]

instructionsText = [
    "Available commands are:",
    "",
    "instructions         -- to see these instructions.",
    "look                 -- to look around you.",
    "enter Room           -- to enter another room.",
    "goTo Object          -- to go to the object.",
    "examine Object       -- to look closer at the object.",
    "quit                 -- to end the game and quit.",
    ""
    ]

data GameState = GameState { currentRoom :: Room, nextToObject :: String, found_office_key :: Bool, remember_names :: Bool, remember_stress :: Bool, found_kitchen_note :: Bool, found_knife :: Bool, found_bedroom_letter :: Bool, found_bed :: Bool, crowbarFound :: Bool, bodyFound :: Bool, happyEnding :: Int, startAgain :: Bool }

-- define rooms
data Room = Room { roomName :: String, roomItems :: [String] }

hall:: Room
hall = Room "hall" ["front_door", "office_door", "wardrobe", "umbrella", "plant", "dresser", "painting"]

office :: Room
office = Room "office" ["office_door", "desk", "chair", "computer", "bookshelf", "piano"]

kitchen :: Room
kitchen = Room "kitchen" ["kitchen_door", "table", "fridge", "window", "attic_door"]

bedroom :: Room
bedroom = Room "bedroom" ["bedroom_door", "bed", "bedside_table", "closet", "wife"]

garage :: Room
garage = Room "garage" ["garage_door", "car", "tool_shelf"]

attic :: Room
attic = Room "attic" ["body", "attic_door"]

-- describe rooms
describeRoom :: Room -> [String]
describeRoom room = ["You are in " ++ roomName room]

listItems :: Room -> [String]
listItems room = ["There are: \n" ++ intercalate "\n" (map (\item -> "- " ++ item) (roomItems room))]

-- look function
look :: GameState -> [String]
look currentState = (describeRoom (currentRoom currentState)) ++ (listItems (currentRoom currentState))

-- enter another room function
enter :: GameState -> String -> ([String],GameState)
enter gameState destination
    | destination == "hall" && nextToObject gameState == "front_door" = changeRoom gameState hall
    | destination == "office" && nextToObject gameState == "office_door" && found_office_key gameState == True = changeRoom gameState office
    | destination == "kitchen" &&  nextToObject gameState == "kitchen_door" = changeRoom gameState kitchen
    | destination == "kitchen" && nextToObject gameState == "bedroom_door" && found_bedroom_letter gameState == True && found_bed gameState == True = changeRoom gameState kitchen
    | destination == "bedroom" && nextToObject gameState == "kitchen_door" && found_kitchen_note gameState == True && found_knife gameState == True = changeRoom gameState bedroom
    | destination == "garage" && nextToObject gameState == "kitchen_door" && found_bedroom_letter gameState == True && found_bed gameState == True && found_kitchen_note gameState == True && found_knife gameState == True = changeRoom gameState garage
    | destination == "attic" && nextToObject gameState == "garage_door" && crowbarFound gameState == True = changeRoom gameState attic
    | otherwise = (["You cannot enter this room"], gameState)

-- goTo object
-- returns description and Room so you can use updated room to gameLoop
goTo :: GameState -> String -> ([String], GameState)
goTo gameState item

    -- HALL
    | item == "front_door" && roomName (currentRoom gameState) == "hall" =
        (["Oh no! I\'m trying to open the front door, but it seems like it\'s closed.",
        "Maybe I\'ll try to look around and see if I can find some clues."],
        gameState { nextToObject = "front_door" })

    | item == "office_door" && roomName (currentRoom gameState) == "hall" && not (found_office_key gameState == True) =
        (["This door is closed. Maybe I can find some key that opens it."],
        gameState { nextToObject = "office_door" })

    | item == "office_door" && roomName (currentRoom gameState) == "hall" && (found_office_key gameState == True) =
        (["I found a key in the drawer in the dresser! Now I can enter this room.",
        "Type \'enter office\' to go inside"],
        gameState { nextToObject = "office_door" })
    | item == "dresser" && roomName (currentRoom gameState) == "hall" =
        (["I found a key in the drawer. I wonder what it opens."] , gameState { nextToObject = "dresser", found_office_key = True})

    | item == "wardrobe" && roomName (currentRoom gameState) == "hall" =
        (["There is a big old wardrobe here. Inside I can see coats that belong to a female."], gameState { nextToObject = "wardrobe" })

    | item == "umbrella" && roomName (currentRoom gameState) == "hall" =
        (["I found an umbrella. It\'s kinda useless, cause I\'m inside the building."], gameState { nextToObject = "umbrella" })

    | item == "plant" && roomName (currentRoom gameState) == "hall" =
        (["Oh! There\'s a note behind the plant! It looks like sheet of paper from some notebook. Let\'s see what is written on this note.",
        "\'Got home tired, found a candlelit dinner in the backyard, thanks to my wife. Made my day!\'."]  ++ (chooseThoughts gameState item), gameState { nextToObject = "plant" })

    | item == "painting" && roomName (currentRoom gameState) == "hall" =
        (["Oh! There\'s a note below the painting! It looks like sheet of paper from some notebook. Let\'s see what is written on this note.",
        "\'Today, my wife surprised me with breakfast in bed.\'.",
        "\'Waking up to the smell of freshly brewed coffee and the sight of my favorite pancakes made me feel incredibly loved and appreciated.\'."] ++ (chooseThoughts gameState item), gameState { nextToObject = "painting" })

    -- OFFICE
    | item == "office_door" && roomName (currentRoom gameState) == "office" =
        (["I am in the office. I should look around and see what is here."], gameState { nextToObject = "office_door" })

    | item == "desk" && roomName (currentRoom gameState) == "office" =
        let (squeakMessages, updatedGameState) = lock_squeaks gameState
        in (["'Oh! There\'s another note on the desk!",
        "\'Me and my best friend had a great time in the park, laughing and snacking on a cozy blanket. It\'s moments like these that make life awesome.\'."] ++ squeakMessages, updatedGameState { nextToObject = "desk" })

    | item == "chair" && roomName (currentRoom gameState) == "office" =
        let (squeakMessages, updatedGameState) = lock_squeaks gameState
        in (["There is a chair here. It looks like someone was sitting here recently."] ++ squeakMessages, updatedGameState { nextToObject = "chair" })

    | item == "computer" && roomName (currentRoom gameState) == "office" =
        (["Someone left their computer without logging off, let\'s see if I can find some things that that might spark my memories",
          "Write a command: \"examine computer.\" in order to search for some clues." ], gameState { nextToObject = "computer" })

    | item == "bookshelf" && roomName (currentRoom gameState) == "office" =
        let (squeakMessages, updatedGameState) = lock_squeaks gameState
        in (["There is a bookshelf here. There\'s anoter note here!",
        "\'I have so much work to do! I can\'t find time for my wife... I am so stressed out that sometimes I can\'t contol my emotions...\'." ] ++ squeakMessages ++ (chooseThoughts gameState item), updatedGameState { nextToObject = "bookshelf" , remember_stress = True})
    
    | item == "kitchen_door" && roomName (currentRoom gameState) == "office"=
        (["Let\'s go to the kitchen!"], gameState { nextToObject = "kitchen_door" })
    
    | item == "piano" && roomName (currentRoom gameState) == "office" =
        (["There is some sheet music on the piano. I wonder what song it is. Maybe I can take a closer look."], gameState { nextToObject = "piano" })

    -- KITCHEN
    | item == "table" && roomName (currentRoom gameState) == "kitchen" =
        (["There is a table here. Looks like someone was preparing meat for dinner.",
        "There is a knife lying next to it."],
        gameState { currentRoom = (addItemToRoom (currentRoom gameState) "knife"), nextToObject = "table" } )
    | item == "knife" && roomName (currentRoom gameState) == "kitchen" =
        (["It was on the table. I need to go to the table first and then examine knife."], gameState)

    | item == "fridge" && roomName (currentRoom gameState) == "kitchen" =
        (["This fridge is covered with colorful magnets and written notes.",
        "And there is a calendar hanging on the fridge."],
        gameState { currentRoom = (addItemToRoom (addItemToRoom (addItemToRoom (currentRoom gameState) "calendar") "shopping_list") "folded_note"), nextToObject = "fridge" } )
    | item == "calendar" && roomName (currentRoom gameState) == "kitchen" =
        (["It was on the fridge. I need to go to the fridge first and then examine calendar"], gameState)
    | item == "shopping_list" && roomName (currentRoom gameState) == "kitchen" =
        (["It was on the fridge. I need to go to the fridge first and then examine shopping_list"], gameState)
    | item == "folded_note" && roomName (currentRoom gameState) == "kitchen" =
        (["It was on the table. I need to go to the table first and then examine knife"], gameState)
    
    | item == "window" && roomName (currentRoom gameState) == "kitchen" =
        (["This is kitchen window.",
        "It\'s pretty dark outside.",
        "It hard to see what\'s out there."], gameState { nextToObject = "window" })
    
    | item == "kitchen_door" && roomName (currentRoom gameState) == "kitchen" && not (found_kitchen_note gameState == True && found_knife gameState == True) =
        (["I have to find out more before I will go somewhere else..."], gameState { nextToObject = "kitchen_door" })
    
    | item == "kitchen_door" && roomName (currentRoom gameState) == "kitchen" && found_kitchen_note gameState == True && found_knife gameState == True =
        (["Let's go back to the hall and then I will go to the bedroom "], gameState { nextToObject = "kitchen_door" })

    -- BEDROOM
    | item == "closet" && roomName (currentRoom gameState) == "bedroom" =
        (["I approach the closet. It is slightly open.",
        "Inside I see some clothes and shoes.",
        "But I don\'t plan to dressing up so... no use"],
        gameState { nextToObject = "closet" } )
    
    | item == "bedside_table" && roomName (currentRoom gameState) == "bedroom" =
        (["I am next to the bedside_table. There is a lamp on it.'",
        "And there seems to be a folded note under the lamp.",
        "Oh it is some kind of letter."],
        gameState { currentRoom = (addItemToRoom (currentRoom gameState) "letter"), nextToObject = "bedside_table" } )
    | item == "letter" && roomName (currentRoom gameState) == "bedroom" =
        (["It was on the bedside_table. I need to go to the bedside_table first and then examine letter"], gameState)
    
    | item == "wife" && roomName (currentRoom gameState) == "bedroom" =
        (["Vanessa? Vanessa, what is going on?",
        "She is sitting on the bed, crying.",
        "I try to speak to her, but she does not respond.",
        "It seems like she cannot see me. What is happening?"],
        gameState { nextToObject = "wife" })
    
    | item == "bed" && roomName (currentRoom gameState) == "bedroom" =
        (["Is the bed on which Vanessa is sitting",
        "She is still crying.",
        "Why did you do it?? Oh whyy",
        "I want to help her, but she is not hearing me",
        "Maybe in garage I will something to break door and go to the attic"],
        gameState { nextToObject = "bed", found_bed = True } )
    
    | item == "bedroom_door" && roomName (currentRoom gameState) == "bedroom" && not (found_bedroom_letter gameState == True && found_bed gameState == True) =
        (["I have to find out more..."], gameState { nextToObject = "kitchen_door" })
    
    | item == "bedroom_door" && roomName (currentRoom gameState) == "bedroom" && found_bedroom_letter gameState == True && found_bed gameState == True =
        (["I should go back to the hall and then go to the garage"], gameState { nextToObject = "bedroom_door" })
    
    -- GARAGE
    | item == "car" && roomName (currentRoom gameState) == "garage" =
        (["Oh it\'s beautiful! 1964 Pontiac GTO...",
        "I spent hours repering it! We had so many nice trips with Vanessa in this car.",
        "And with Charlie...",
        "I must find a tool to open that attic though, let\'s focus on that now"], gameState { nextToObject = "car" } )
    | item == "tool_shelf" && roomName (currentRoom gameState) == "garage" = 
        (["There are piles of screws and scraps of papers...",
        "Crap, I am not a tidy person, I hope I will find something though"], gameState { nextToObject = "tool_shelf" })
    | item == "garage_door" && roomName (currentRoom gameState) == "garage" && crowbarFound gameState == False =
        (["I have to find something to open that attic door first..."], gameState { nextToObject = "garage_door" })
    | item == "garage_door" && roomName (currentRoom gameState) == "garage" && crowbarFound gameState == True =
        (["Let\'s go to that attic now..."], gameState { nextToObject = "garage_door" })
    -- ATTIC
    | item == "attic_door" && roomName (currentRoom gameState) == "attic" && bodyFound gameState == False =
        (["Why there is a body here? Let\'s just check it real quick..."], gameState { nextToObject = "attic_door" })
    | item == "attic_door" && roomName (currentRoom gameState) == "attic" && bodyFound gameState == True =
        (["Oh my God! I have to get out of here...", 
        "If I stay here a second longer I will go insane!"] ++ finale, gameState  { nextToObject = "attic_door" })
    | item == "body" && roomName (currentRoom gameState) == "attic" =  
        (["No, no, NO! It's Charlie! He's all covered in blood...",
        "He\'s got two... no, three wounds in his chest...",
        "Blood is oozing from cuts, contrasting with his pale skin...",
        "I have to find something to stop the bleeding!"], 
        gameState { currentRoom = (addItemToRoom (currentRoom gameState) "fabric"), nextToObject = "body" })
    | item == "fabric" && roomName (currentRoom gameState) == "attic" =
        (["This should work!",
        "Write save_charlie to use fabric to stop the bleeding."], gameState {nextToObject = "fabric"})
    | elem item (roomItems (currentRoom gameState)) = 
        (["I guess it's just " ++ item ++ ". Nothing to see here."], gameState)
    | otherwise = (["There is no object like this nearby."], gameState)



examine :: GameState -> String -> ([String], GameState)
examine gameState item
    -- it has to be first as you can examine phone being next to body
    | item == "phone" && roomName (currentRoom gameState) == "attic" && nextToObject gameState == "body" =
        (["Yes, they had some secret meetings... They don\'t talk about their relationship though...",
        "They\'re talking about ME! But not in a bad way, they are worried...",
        "Worried about me? Vanessa writes that I\'m not in the best mental place",
        "That I am impulsive, under a lot of stress, that I started seeing things...",
        "Suddenly I hear another voice... no emotions in it, almost as it wasn\'t exactly human one..."] ++ (charlie_talks),
        gameState { bodyFound = True })
    
    --OFFICE
    | item == "computer" && roomName (currentRoom gameState) == "office" && nextToObject gameState == "computer" =
        let (squeakMessages, updatedGameState) = lock_squeaks gameState
        in (["I found a folder named \"Venice_2019\".",
        "I opened the folder and found pictures from the trip that apparently me and some guy went on together.",
        "In another folder named \"My beautiful wife\" I found photos of a some female.",
        "Oh god! I found a picture from the wedding! The guy that she has married is me! This is my wife!",
        "I\'ve just recalled her name! It\'s Vanessa! And the guy on previous photos is my best friend, Charlie!",
        "And this is my house! And notes from MY notebook! I need to know what happened!"] ++ squeakMessages, updatedGameState { remember_names = True })

    | item == "computer" && roomName (currentRoom gameState) == "office" && nextToObject gameState == "computer" && remember_names gameState == True =
        (["There are so many beaufiful photos of my wife, Vanessa on this computer. I love her so much.",
        "Oh, here is a photo of me and Charlie from our childhood. He is such a good friend of mine."], gameState)
    
    | item == "piano" && roomName (currentRoom gameState) == "office" && nextToObject gameState == "piano" =
        (["I found a sheet music for the song \"Moonlight Sonata\".",
        "I remember that I used to play it for my loved one when we were dating."] ++ (chooseThoughts gameState item), gameState)

    
    -- KITCHEN
    | item == "calendar" && roomName (currentRoom gameState) == "kitchen" && nextToObject gameState == "fridge"=
        (["It is calendar with fun photo of dog.",
        "Today\'s date is circled in red with Charlie\'s name",
        "Maybe he is coming here today. I would love to see my dear friend"], gameState)
    | item == "calendar" && roomName (currentRoom gameState) == "kitchen" && not (nextToObject gameState == "fridge")=
        (["It was on the fridge. I need to go to the fridge first"], gameState)
    
    | item == "shopping_list" && roomName (currentRoom gameState) == "kitchen" && nextToObject gameState == "fridge"=
        (["It is shopping list.",
        "It contains items like milk, bread, and eggs.",
        "Seems like a typical grocery list."], gameState)
    | item == "shopping_list" && roomName (currentRoom gameState) == "kitchen" && not (nextToObject gameState == "fridge")=
        (["It was on the fridge. I need to go to the fridge first"], gameState)
    
    | item == "folded_note" && roomName (currentRoom gameState) == "kitchen" && nextToObject gameState == "fridge"=
        (["I am unfolding the note.",
        "Oh! It looks like another note from my notebook!",
        "The note says:",
        "I cannot believe it! How could he do this to me? I trusted him with everything.",
        "He was so important to me, but now... The pain is unbearable."] ++ (chooseThoughts gameState item), gameState { found_kitchen_note = True })
    | item == "folded_note" && roomName (currentRoom gameState) == "kitchen" && not (nextToObject gameState == "fridge")=
        (["It was on the fridge. I need to go to the fridge first"], gameState)

    | item == "knife" && roomName (currentRoom gameState) == "kitchen" && nextToObject gameState == "table"=
        (["This knife is really large.",
        "It is covered in blood.",
        "The blood does not seem to be from the meat.",
        "It looks weird..."], gameState { found_knife = True })
    | item == "knife" && roomName (currentRoom gameState) == "kitchen" && not (nextToObject gameState == "table")=
        (["It was on the table. I need to go to the table first"], gameState)
    
    -- BEDROOM
    | item == "letter" && roomName (currentRoom gameState) == "bedroom" && nextToObject gameState == "bedside_table"=
        (["Dear Vanessa",
        "last meeting was everything what we needed.",
        "Can\'t wait to see you tonight and arrange everything",
        "Charlie",
        "What is this letter? What it is means?!"] ++ (chooseThoughts gameState item), gameState { found_bedroom_letter = True })
    | item == "letter" && roomName (currentRoom gameState) == "bedroom" && not (nextToObject gameState == "bedside_table")=
        (["It was on the bedside_table. I need to go to the bedside_table first"], gameState)
    
    | item == "wife" && roomName (currentRoom gameState) == "bedroom"=
        (["Vanessa! Are you hearing me?"] ++ (chooseThoughts gameState item), gameState)
    

    | not(elem item (roomItems (currentRoom gameState)))= 
        (["There is no object like this nearby."], gameState) 
    | item /= nextToObject gameState =
        (["I have to be near " ++ item ++ " to examine it further..."], gameState)
    
    -- GARAGE
    | item == "car" && roomName (currentRoom gameState) == "garage" =
        (["The car is locked, I must have left the keys somewhere",
        "It\'s not important now, let\'s find a way to open that attic"], gameState)
    | item == "tool_shelf" && roomName (currentRoom gameState) == "garage" =
        (["Oh yes! Between hammers I found crowbar!",
        "That should do it! Now I can use this to open attic door..."], gameState { crowbarFound = True })
    | item == "body" && roomName (currentRoom gameState) == "attic" = 
        (["He\'s holding a phone... I remember now - he tried showing me something...",
        "Probably evidence of their betrayal... Yes, let\'s see their texts..."],
        gameState { currentRoom = (addItemToRoom attic "phone") } )

    | otherwise = (["I guess it's just " ++ item ++ ". Nothing to see here."], gameState)

changeRoom :: GameState -> Room -> ([String], GameState)
changeRoom gameState newRoom = 
    (["You are entering " ++ roomName newRoom ++ "."], gameState { currentRoom = newRoom })

-- add Item to room and return room
addItemToRoom :: Room -> String -> Room
addItemToRoom room newItem = room { roomItems = newItem : roomItems room  }

-- EXTRA FUNCTIONS 

chooseOption :: GameState -> String -> IO GameState
chooseOption gameState optionnr = do
    case optionnr of
        "1" -> do
            newHappyEnding <- addRandomPositive (happyEnding gameState)
            return gameState { happyEnding = newHappyEnding }
        "2" -> do
            newHappyEnding <- addRandomNegative (happyEnding gameState)
            return gameState { happyEnding = newHappyEnding }
        _   -> return gameState


chooseThoughts :: GameState -> String -> [String]
chooseThoughts gameState item =
    let optionsText = [" ",
                       "What do you think of that? Type either 'option 1' or 'option 2'. Your choice might impact future events."]
    in optionsText ++ case item of
        "plant" | roomName (currentRoom gameState) == "hall" -> 
            ["1. That was very thoughtful of her! I wish I had a partner like that.",
             "2. She might be trying to make up for something she did wrong to her husband."]
        "painting" | roomName (currentRoom gameState) == "hall" ->
            ["1. Ohh that is so sweet! If I were him, I would do the same for my wife.",
             "2. I'm so jealous, I would literally KILL for a breakfast like that!"]
        "bookshelf" | roomName (currentRoom gameState) == "office" ->
            ["1. Learning how to manage your emotions is such an important thing. We don't want to hurt our close ones.",
             "2. We othen cannot control our emotions, other peaople should understand that."]
        "folded_note" | roomName (currentRoom gameState) == "kitchen" && nextToObject gameState == "fridge"->
            ["1. I wonder what happened. I will not jump into any conclusions before I know the whole story.",
             "2. I bet he did something terrible. I can't wait to find out what it was."]
        "letter" | roomName (currentRoom gameState) == "bedroom" && nextToObject gameState == "bedside_table" ->
            ["1. I wonder what they were arranging. I hope that it wasn't anything bad, but I have bad feeling about it.",
             "2. I can't believe it! I trusted him with everything and he betrayed me!"]
        "piano" | roomName (currentRoom gameState) == "office" && nextToObject gameState == "piano" ->
            ["1. Yes, I should play it. It might help me remember something.",
             "2. No, don't waste time on this. I have to find out what happened."]
        "wife" | roomName (currentRoom gameState) == "bedroom" ->
            ["1. I have to help her, I can't stand seeing her like this!",
             "2. Why is she crying?! The one that did this to her is gonna regret this!."]
        _ -> [""]
    
    

addRandomPositive :: Int -> IO Int
addRandomPositive x = do
    randomNum <- randomRIO (1, 10) 
    return (x + randomNum) 

addRandomNegative :: Int -> IO Int
addRandomNegative x = do
    randomNum <- randomRIO (1, 10) 
    return (x - randomNum)       


lock_squeaks :: GameState -> ([String], GameState)
lock_squeaks gameState
    | (remember_names gameState == True) && (remember_stress gameState == True) =
        (["I heard a squeak from the lock. Oh, I think this sound came from the kitchen! I can go there now!'"], gameState { currentRoom = addItemToRoom (currentRoom gameState) "kitchen_door"})
    | otherwise = ([""], gameState)

save_charlie :: GameState -> ([String], GameState)
save_charlie gameState
    | elem "fabric" (roomItems (currentRoom gameState)) =
        (["I\'m pushing fabric against wounds, but blood just keeps coming...",
        "Now my hands are covered in scarlet fluid and I can\'t help but sob...",
        "My dear friend... what happened? Who could have done this...",
        "That\'s why Vanessa is crying... Right, but Charlie and Vanessa...",
        "Now it\'s all coming together... My notes and theirs letters...",
        "I feel extreme anger, I almost can\'t think clearly...",
        "I know who did this. But it was fair punishment for betraying me... HE DESERVED THIS!",
        "I see something glowing in Charlie\'s hand... What is it?"], gameState { currentRoom = addItemToRoom (currentRoom gameState) "phone", nextToObject = "body"})
    | otherwise = (["Unknown command."], gameState)

charlie_talks :: [String]
charlie_talks =
    ["\"Deep down you knew we didn\'t do it... You knew and you still did it...",
    "Even though I showed our texts... You didn\'t listen...\"",
    "write look_up. to see who spoke"]

look_up :: GameState -> [String]
look_up gameState
    | bodyFound gameState == True && nextToObject gameState == "body" =
        ["Frightened I look up from the phone... And I look right into eyes...",
        "Charlie\'s eyes... But they\'re empty now... They always had a spark of joy in them...",
        "Then Charlie openes his mouth once again and speaks with this unreal, dead voice...",
        "\"You remember it now, right? How you took knife from kitchen... chased me here - to the attic...\"",
        "I tell him to stop... Just don\'t finish, please... I BEG YOU!",
        "But he does finish... And all my fears become reality... My whole life shatters...",
        "I see those terrifying scenes happening just before my eyes...",
        "My hands covered in blood... Just like they are now...",
        "I have to get out of here..."]
    | otherwise = ["Unknown command."]

finale :: [String]
finale =
    ["I pass through what\'s left from attic door...",
    "\"Why did you do it...\" I hear Vanessa, my lovely wife still crying in the bedroom...",
    "I\'m sorry! I\'M SO SORRY! It wasn\'t meant to be like this...",
    "I feel like I\'m suffocating in this damn house!",
    "I managed to run to the hall, I see the front door, I can get out of this madness",
    "Write \'ending\'"]


chooseEnding :: GameState -> ([String], GameState)
chooseEnding gameState
    | happyEnding gameState >= 70 =
        (["It's open now! I open them and I feel calm sensation in my chest...",
        "I've been here so many times, relived it and paid for my actions",
        "I have finally been forgiven I think...",
        "I can go now... But where?",
        "I guess just forward...",
        "THE END"], gameState)
    | otherwise =
        (["It\'s open now! I run through them...",
        "I don\'t even look around, I just wanna run as far as possible...",
        "I just don\'t want to hear this crying anymore...",
        "Suddenly my boots step on something hard, like wood...",
        "I hear door closing behind me and I now know what will happen...",
        "It will happen again... As it did so many times before..."],
         gameState { startAgain = True })

-- print strings from list in separate lines
printLines :: [String] -> IO ()
printLines xs = putStr (unlines xs)
                  
printIntroduction = printLines introductionText
printInstructions = printLines instructionsText

readCommand :: IO String
readCommand = do
    putStr "> "
    xs <- getLine
    return xs
    
-- note that the game loop may take the game state as
-- an argument, eg. gameLoop :: State -> IO ()
gameLoop :: GameState -> IO ()
gameLoop gameState = do
    printLines ["", ""]
    cmd <- readCommand
    case words cmd of
        ["instructions"] -> do {printInstructions; gameLoop gameState}
        ["look"] -> do
            printLines (look gameState)
            gameLoop gameState
        ["enter", destination] -> do 
            let (roomDesc, newState) = enter gameState destination
            if roomDesc /= [""]
                then do
                    printLines (roomDesc)
                    gameLoop newState
                else do
                    printLines ["There is no such room nearby."]
                    gameLoop newState
        ["goTo", object] -> do
            let (objectDesc, updatedGameState) = goTo gameState object
            printLines objectDesc
            gameLoop updatedGameState
        ["examine", object] -> do
            let (objectDesc, updatedGameState) = examine gameState object
            printLines objectDesc
            gameLoop updatedGameState
        ["save_charlie"] -> do
            let (saveDesc, updatedGameState) = save_charlie gameState
            printLines saveDesc
            gameLoop updatedGameState
        ["look_up"] -> do
            printLines (look_up gameState)
            gameLoop gameState
        ["option", optionnr] -> do
            updatedGameState <- chooseOption gameState optionnr
            gameLoop updatedGameState
        ["ending"] -> do
            let (endingDesc, updatedGameState) = chooseEnding gameState
            printLines endingDesc
            if startAgain updatedGameState == True
                then do
                    let initialGameState = GameState hall "front_door" False False False False False False False False False 50 False
                    gameLoop initialGameState
                else return ()
        ["quit"] -> return ()
        _ -> do printLines ["Unknown command.", ""]
                gameLoop gameState

main :: IO ()
main = do
    let initialGameState = GameState hall "front_door" False False False False False False False False False 50 False
    printIntroduction
    printInstructions
    gameLoop initialGameState