1. Create a Trigger That Adds 3 tasks with the subject "green", "blue", "red" to the opportunity record
2. Only add the task if there isn't an existing open task with that subject name (the trigger should be able to run multiple times without creating duplicate open tasks)
3. The logic should be triggered when the opportunity stage field is changed to "Needs Analysis"
4. The code should by dynamic and not have any hard coded logic about task subjects, or number of tasks like if(red), if(task1) it should written in a way that is easy to add more subject names without the need of much code modification
5. The apex logic should also be able to be called at the opportunity page as an action button to be able to be run manually

## PACKAGE DEMO PREREQUISITES

1. Move to "Opportunity Subject Entries" tab and create a few instances with different values in "Subject Entry" field.
2. In setup move to Opportunity page layout and add "Add tasks" quick action from Lightning Actions list to Opportunity layout actions.

## DEMO STEPS

1. Move to opportunities tab and create new opportunity record.
2. Change its stage name to "Needs Analysis" or press "Add tasks" button. If opportunity has no active tasks with the subject values, which were written in prerequisites, respective tasks will be created.
3. You can repeat the procedure of Demo Step 2 with some of the active tasks or with all the active tasks to ensure that it works safely.
