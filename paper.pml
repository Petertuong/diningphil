#define N 5

mtype = { THINKING, HUNGRY, EATING };
mtype = { REQ, LEAVE, GRANT };

mtype phil[N];          /* status of philosopher i */
bool  chopstick[N];     /* true = up; philosopher i uses i and (i+1)%N */
// bool  token[N];         /* philosopher i holds the token (redundant)*/
bool  queued[N];        /* agent has accepted i's request, not yet granted (for checking)*/

chan hungryQ  = [N] of { byte };          /* FCFS queue of hungry philosophers */
chan toAgent  = [0] of { mtype, byte };   /* rendezvous: philosopher -> agent */
chan reply[N] = [1] of { mtype };         /* agent -> philosopher i */

#define LEFT(i)  (i)
#define RIGHT(i) (((i) + 1) % N)

proctype P(byte id) {
    do
    :: phil[id] = HUNGRY;
       toAgent ! REQ, id;
       reply[id] ? GRANT;
       phil[id] = EATING;
       printf("Philosopher %d is eating\n", id);
       phil[id] = THINKING;          /* stop eating BEFORE telling the agent */
       toAgent ! LEAVE, id;
       printf("Philosopher %d is thinking\n", id)
    od
}

proctype A() {
    byte id;
    byte cur = N;                               /* head of the queue, N = none */
    do
    :: toAgent ? REQ, id -> atomic { queued[id] = true; hungryQ ! id }
    :: cur == N && nempty(hungryQ) -> hungryQ ? cur   /* take the next in line */
    :: cur < N && !chopstick[LEFT(cur)] && !chopstick[RIGHT(cur)] ->
         atomic {
           chopstick[LEFT(cur)]  = true;
           chopstick[RIGHT(cur)] = true;
        //    token[cur] = true;
           queued[cur] = false;
           reply[cur] ! GRANT;
           cur = N
         }
    :: toAgent ? LEAVE, id ->
         atomic {
           chopstick[LEFT(id)]  = false;
           chopstick[RIGHT(id)] = false;
        //    token[id] = false
         }
    od
}

init {
    byte i;
    atomic {
        for (i : 0 .. N-1) { phil[i] = THINKING; run P(i)}
        run A()
    }
}

/* neighbours never eat at the same time */
ltl mutex   { [] !( (phil[0] == EATING && phil[1] == EATING)
                 || (phil[0] == EATING && phil[4] == EATING)
                 || (phil[1] == EATING && phil[2] == EATING) 
                 || (phil[2] == EATING && phil[3] == EATING)
                 || (phil[3] == EATING && phil[4] == EATING)) }
/* a hungry philosopher eventually eats (needs weak fairness: pan -f) */
ltl nostarve { [] (phil[0] == HUNGRY -> <> (phil[0] == EATING)) }
/* once the agent has accepted the request, the philosopher eventually eats */
ltl served { [] (queued[0] -> <> (phil[0] == EATING)) }