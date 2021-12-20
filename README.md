1. Create a Trigger That Adds 3 tasks with the subject "green", "blue", "red" to the opportunity record
2. Only add the task if there isn't an existing open task with that subject name (the trigger should be able to run multiple times without creating duplicate open tasks)
3. The logic should be triggered when the opportunity stage field is changed to "Needs Analysis"
4. The code should by dynamic and not have any hard coded logic about task subjects, or number of tasks like if(red), if(task1) it should written in a way that is easy to add more subject names without the need of much code modification
5. The apex logic should also be able to be called at the opportunity page as an action button to be able to be run manually



answers 
1. object with many relationships:      quote, case, opportunity

2. object with one relationship         ???

3. object with many to many relationships: 
                                        тут надо конкретно два объекта между которыми связь или junction object просто выписать? opportunity<->product/opportunity product, order<->product/order product
                                        
4. when master detail is used :         
                                        master detail is used in the following scenarios: 
                                        1) to provide tightly coupled relationship, in case master is deleted - all the details are deleted as well 
                                        2) to prevent creating detail records without parent 
                                        3) to inherit sharing rules from parent to child 
                                        4) to use rollup summary functionality 
                                        5)to create junction objects

5. what is a bucket field:              
                                        bucketing lets developer group data into various ranges and segments    without a need from complex fields and formulas
6. what is a run user 
                                        Each dashboard has a running user, whose security settings determine which data to display in a dashboard.

7. permission sets vs profiles
                                        permission sets provide more flexibility in security and accessibility features. 
                                        for example we have 5 users with the same profile and therefore same security for this users. but if user 4 wants different security features i will define permission set, assign it to user 4 and it won't affect remaining users. 