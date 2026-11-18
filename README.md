# diningphil
This project modelling the algorithm from "Agent based dining philosopher problem"  by Deepshikha Bhargava1 , Sonali Vyas. Then I check for the claim of safety and liveness property as claimed by the paper (without proof)

Generally, we found that under N = 5 and N = 3 (Tested cases, but I want to avoid generalisation without proper proof):
  - Mutex between neighbors is achievable even without fairness assumption.
  - Once the philosopher request got accepted, they will eventually eat
  - But if the philosopher is just hungry, without being accepted for the request, even under weak fairness assumption, he can starve (this is due to the design of rezvendous (phil -> agent) channel). => A possible fix could be to separate channel for each phil -> agent, provide buffer, etc. (But the intention of the paper is unclear)

The algorithm in the paper, however is ambiguous and redundant in many ways. Thus there are branches would never be reachable, I refuse to model it in promela. There is some redundancy such as token, that removing it affect none to the behavior of the program. Thus the paper either is not showing the detail role of token or is over claiming.
