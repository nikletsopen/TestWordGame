# TestWordGame
Simple word pair game implemented with TCA architecture 

### How much time was invested: 
About 6 hours of concetrated work 

### How was the time distributed (concept, model layer, view(s), game mechanics): 
  - Concept - 1 hour
  - Model layer - 2 hours
  - View(s) - 1 hour
  - Game mechanics - 1 hour
  - Tests - 1 hour
### Decisions made to solve certain aspects of the game: 
  - Introduced TCA architecture to better hanlde different state changes
  - Reshuffle tasks each time after fetching to make things more interesting
  - When user "quits" - reset the state after he comes back (an app becomes active again)
### Decisions made because of restricted time: 
  - Kept all logic in one reducer
  - Falling anuimation is not linked directly to timer, but uses the same global constant 
### What would be the first thing to improve or add if there had been more time:
There are several things I'd like to improve. Below they are listed by priority: 
  - Break the reducer into smaller pieces
  - Separate fetching and pasring logic 
  - Add localization for strings
  - Add linter and formatter
  - Use "exhaustivity" param to make test more concise
  - Write more tests
  - Improve falling animation
  - Make the false asnwers percentage adjustable 
