

Table of Contents
=================
   * [Εγκατάσταση](#εγκατάσταση)
      * [Απαιτήσεις](#απαιτήσεις)
      * [Οδηγίες Εγκατάστασης](#οδηγίες-εγκατάστασης)
   * [Περιγραφή API](#περιγραφή-api)
      * [Methods](#methods)
         * [Board](#board)
            * [Ανάγνωση Board](#ανάγνωση-board)
            * [Αρχικοποίηση Board](#αρχικοποίηση-board)
            * [Αποστολή Επιλογής](#αποστολή-επιλογής)
            * [Play Again](#play-again)
         * [Player](#player)
            * [Ανάγνωση στοιχείων παίκτη](#ανάγνωση-στοιχείων-παίκτη)
            * [Καθορισμός στοιχείων παίκτη](#καθορισμός-στοιχείων-παίκτη)
         * [Status](#status)
            * [Ανάγνωση κατάστασης παιχνιδιού](#ανάγνωση-κατάστασης-παιχνιδιού)
      * [Entities](#entities)
         * [Board](#board-1)
         * [Players](#players)
         * [Game_status](#game_status)
   * [Pictures](#pictures)


# Demo Page

Μπορείτε να κατεβάσετε τοπικά ή να επισκευτείτε την σελίδα: 
https://users.it.teithe.gr/~it185320/ADISE21_RPSLS/www/



# Εγκατάσταση

## Απαιτήσεις

* Apache2
* Mysql Server
* php

## Οδηγίες Εγκατάστασης

 * Κάντε clone το project σε κάποιον φάκελο <br/>
  `$ https://github.com/iee-ihu-gr-course1941/ADISE21_RPSLS.git`

 * Βεβαιωθείτε ότι ο φάκελος είναι προσβάσιμος από τον Apache Server. πιθανόν να χρειαστεί να καθορίσετε τις παρακάτω ρυθμίσεις.

 * Θα πρέπει να δημιουργήσετε στην Mysql την βάση με όνομα 'rpsls' και να φορτώσετε σε αυτήν την βάση τα δεδομένα από το αρχείο schema.sql

 * Θα πρέπει να φτιάξετε το αρχείο lib/config_local.php το οποίο να περιέχει:
```
    <?php
	$DB_PASS = 'κωδικός';
	$DB_USER = 'όνομα χρήστη';
    ?>
```

# Περιγραφή Παιχνιδιού

**Το Rock, Paper, Scissors, Lizard, Spock παίζεται ως εξής:**
 - Scissors cuts Paper
 - Paper covers Rock
 - Rock crushes Lizard
 - Lizard poisons Spock
 - Spock smashes Scissors
 - Scissors decapitates Lizard
 - Lizard eats Paper
 - Paper disproves Spock
 - Spock vaporizes Rock
 - (and as it always has) Rock crushes Scissors

**Οι κανόνες είναι οι εξής :**
- Αν φύγει/παραδοθεί ο αντίπαλος, νικάς.
- Αν είναι ανενεργός ή κάνει timeout ο αντίπαλος, νικάς.
- Αν νικήσεις ή χάσεις, παίρνεις και χάνεις ανάλογα πόντους.
- Αν το παιχνίδι καταλήξει σε ισοπαλία, δεν παίρνει κανένας πόντο.


**Η βάση μας κρατάει τους εξής πίνακες και στοιχεία:**
 - board
- board_empty
- game_status
 - players


## Συντελεστές
Alexandros Magos - 185320
Dimitris koutsoupias - 185204

# Περιγραφή API

## Methods


### Board
#### Ανάγνωση Board

```
GET /board/
```

Επιστρέφει το [Board](#Board).

#### Αρχικοποίηση Board
```
POST /board/
```

Αρχικοποιεί το Board, δηλαδή το παιχνίδι. Γίνονται reset τα πάντα σε σχέση με το παιχνίδι.
Επιστρέφει το [Board](#Board).

#### Αποστολή Επιλογής

```
POST /board/make_move/
```
Json Data:

| Field             | Description                 | Required   |
| ----------------- | --------------------------- | ---------- |
| `choice`        | Την επιλογή του παίχτη. (1-5) | yes        |
| `player_number`           | Ο αριθμός του παίχτη που έκανε την κίνηση. | yes    
Στέλνει την επιλογή που διάλεξε ο χρήστης(1-5) και ποιος player την έκανε στο stored procedure (make_move).

#### Play Again

```
POST /board/play_again/
```
Καλεί την stored_procedure ''play_again', για να ξανα παίξεις μαζί με τον ίδιο αντίπαλο


### Player

#### Ανάγνωση στοιχείων παίκτη
```
GET /players/
```

Επιστρέφει τα username όλων των παικτών και τα παιρνάμε στην μεταβλητή players.

#### Καθορισμός στοιχείων παίκτη
```
PUT /players/
```
Json Data:

| Field             | Description                 | Required   |
| ----------------- | --------------------------- | ---------- |
| `username`        | Το username για τον παίκτη. | yes        |
| `player_number`           | Τον player που επέλεξε ο παίκτης. | yes        |


Καλείτε όταν ο παίχτης κάνει login και επιστρέφει τα στοιχεία του παίκτη και ένα token. Το token πρέπει να το χρησιμοποιεί ο παίκτης καθόλη τη διάρκεια του παιχνιδιού.

### Status

#### Ανάγνωση κατάστασης παιχνιδιού
```
GET /status/
```
Επιστρέφει το στοιχείο [Game_status](#Game_status).



## Entities


### Board
---------

Το board είναι ένας πίνακας, ο οποίος στο κάθε στοιχείο έχει τα παρακάτω:

| Attribute                | Description                                  | Values                              |
| ------------------------ | -------------------------------------------- | ----------------------------------- |
| `match_id`                      | Το id του match              | 1..8                                |
| `p1_choice`                      | Η επιλογή/κίνηση του παίχτη 1              | 1..5                               |
| `p2_choice`                | Η επιλογή/κίνηση του παίχτη 2                      | 1..5                              |


### Players
---------

O κάθε παίκτης έχει τα παρακάτω στοιχεία:
| Attribute                | Description                                  | Values                              |
| ------------------------ | -------------------------------------------- | ----------------------------------- |
| `username`               | Όνομα παίκτη                                 | String                              |
| `player_number `            | Τον αριθμό που διάλεξε ο χρήστης να παίξει ας | 'p1/p2'                              |
| `token  `                | To κρυφό token του παίκτη. Επιστρέφεται μόνο τη στιγμή της εισόδου του παίκτη στο παιχνίδι | HEX |
| `last_action`            | To χρώμα που παίζει ο παίκτης                | 'B','W'   


### Game_status
---------

H κατάσταση παιχνιδιού έχει τα παρακάτω στοιχεία:


| Attribute                | Description                                  | Values                              |
| ------------------------ | -------------------------------------------- | ----------------------------------- |
| `status  `               | Κατάσταση             | 'not active', 'initialized', 'started', 'ended', 'aborded'     |
| `p_turn`                 | Ποιου παίκτη είναι η σειρά        | 'p1','p2'                              |
| `result`                 |  To player number του παίκτη που κέρδισε ή "D" αν ήτανε ισοπαλία |'p1','p2', 'D'                              |
| `last_change`            | Τελευταία αλλαγή/ενέργεια στην κατάσταση του παιχνιδιού         | timestamp |


# Pictures

![Login Page](/screenshots/login.jpg?raw=true "Login Page")
![In-Game](/screenshots/in-game.jpg?raw=true "In-Game")
![Win - Lose](/screenshots/win_lose.jpg?raw=true "Win - Lose")
![Opponent Leaving](/screenshots/opponent-left.jpg?raw=true "Opponent Leaving")
![Abort](/screenshots/abort.jpg?raw=true "Abort")
