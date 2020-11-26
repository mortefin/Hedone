﻿To use Hedone, download Autohotkey, then double-click Hedone.ahk and press Ctrl+L

Anyone may use this code for anything they want, commercial, personal, governmental, literally anything, just be sure to to credit me.

She's being made to solve very specific word problems, so there isn't much to do with her right now. By default, she stores everything to her temp file. If you'd like to store to her permanent file (concepts.txt), tell her "reset" and then "permanent", or tell her "permanent" before saying anything else.

Here's what it does (with some exceptions), for everything it reads:

1. Splits the message into clauses (usually just by noticing the smiles and stars), and preforms actions 2- for each clause

2. Turns the words into variables, editing them when needed. Plural words turn into their non-plural forms, certain words are joined and treated as if they're only one word (example: "Wonder Woman"), words with punctuation lose their punctuation. This is done so the AI knows which concept in its semantic network each word is referencing.

3. The AI creates a list of connections for each of the words. It does this using its semantic network. Most concepts in its semantic network are connected to other concepts, in simple connections (X is Y) and complex connections (any connection other than X is Y, like X has Y). For simple connections, the AI adds the connected concept to the word's connection-list and also adds the connections that the connected concept has, and the connections of those concepts, etc etc. For complex connections, only the complex connection is added to the connectionlist, but all the connections of the concepts in the complex connection get added to the complex connection (except complex connections).

4. The AI looks at the word classes of all the words (using their connection-lists), and some other things, to determine what the subjects, adjectives, actions and objects of the clause are. It uses, mostly, coded english laws to do this (Ex: if I see a noun before a verb, it is a subject, but if it comes after, it is an object).

5. If the clause is a question, the AI figures out how many of the subjects is the object, or how many of the subjects (verb)s the object, and tells the user. If it's not a question, the AI saves the knowledge it parsed to its semantic network file, either the temporary one or the permanent one. It creates connection(s) from the subject(s) to the object(s), and any found verbs/adjectives. For example, "monkey is an animal" would be a simple connection from Monkey to Animal (Monkey - Animal), but "monkey has four limbs" would be a complex connection from Monkey to Limb that'd look like (money - has 4 - limb).

Concepts in the concepts.txt and temp.txt files:

All numbers, except the exceptions noted below, refence a concept in the concepts file, even the numbers in the temp file. For example, the number "3" in a concepts file with ",noun.,verb.,adjective." would reference adjective because adjective is the third concept in the file.

When linked to a concept, without a verb, Hedone assumes there is an "is always" between the concept and the noun. For example, ",Green.2.,color." would mean "Green is color" aka "Green is a color".

☰ means "this number is literally a number".

skull is a space.

H' before a connection means the connection is a hypothetical. (not yet implemented)

What it does with each word class:

- Preposition -
See: Adjective

- Conjunction -
if the word prior has a star, it treats this word as the beginning of a new clause.

if the word is "if", it learns the clause is a hypothetical and sets "ConIsHypothetical" to 1 but that does nothing. Basically, it does nothing.

if the word is "and", it increases objectcount or verbcount.

if the word is something else, it's ignored.

- Verb -
Sets FoundVerb to 1, so it knows things that could be subjects are actually objects.

If the verb means "be", it sets Action(number) as "be".

- Noun -
Is the subject or object, depending on if a verb has been found. Does not increase objectcount/subjectcount, so it'll write over any previously found -bjects if the -bject count wasnt changed.

- Adjective -
sets "adjofobject%objectcount%" to whatever the word is. 

if the word contains a number, it'll be treated like a number (N put before it in the complexconnection it's in, in whatever file it gets saved to)

- Adverb -
Is the subject or object, depending on if a verb has been found. Does not increase objectcount/subjectcount, so it'll write over any previously found -bjects if the -bject count wasnt changed.

if the word prior has a star, it treats this word as the beginning of a new clause.

- Determiner -
Ignores the word.

if this word isn't "a" or "an", and the previous word was an adverb, it triggers "FindHowMany", meaning it'll use the parsed information in FindHowMany to tell the user how many Xs are Y, instead of saving the information to a file.

- Pronoun -
Is the subject or object, depending on if a verb has been found. Does not increase objectcount/subjectcount, so it'll write over any previously found -bjects if the -bject count wasnt changed.

- No word class -
Is the subject or object, depending on if a verb has been found. Does not increase objectcount/subjectcount, so it'll write over any previously found -bjects if the -bject count wasnt changed.