INCLUDE tricube-tales-pocket-adventures-private.ink

//*******************************
//*                             *
//*  GAMEPLAY HELPER FUNCTIONS  *
//*                             *
//*******************************

=== function loseKarma()

    {
    - characterKarma > 0:
        ~ characterKarma--
        ~ return true
    - else:
        ~ return false
    }

=== function loseResolve()

    {
    - characterResolve > 0:
        ~ characterResolve--
        ~ return true
    - else:
        ~ return false
    }
=== function recoverKarma()

    {
    - characterKarma < MAX_KARMA:
        ~ characterKarma++
        ~ return true
    - else:
        ~ return false
    }

=== function recoverResolve()

    {
    - characterResolve < MAX_RESOLVE:
        ~ characterResolve++
        ~ return true
    - else:
        ~ return false
    }

=== offerComplication(optional_complication, applicable_quirks)

    {
        // short circuit if the complication has already been applied
        - storyComplications ? optional_complication:
            ->->

        // short circuit if the character already has max karma
        - characterKarma >= MAX_KARMA:
            ->->
    }
    
    {
    - LIST_COUNT(applicable_quirks) > 0 and applicable_quirks ? characterQuirk:
        You can recover some karma by being {characterQuirk} right now and taking on {optional_complication}.
            + {characterKarma < MAX_KARMA} [Take the complication.]
                ~ storyComplications += optional_complication
                ~ recoverKarma()
                ->->
            + [Continue as-is.]
                ->->
            -
                ->->
    }

=== challengeCheckWithEffortVersusTimer(target_difficulty, required_effort, maximum_tries, applicable_trait, applicable_concepts, applicable_perks, applicable_quirks, -> goto_failure)

    {
        - maximum_tries > MAX_EFFORT_TRIES:
        !!! ERROR: The storyteller tried to give too many tries ({maximum_tries} vs {MAX_EFFORT_TRIES} max.)
        ->-> goto_failure
    }

    // effort counts up from 0 to required_effort threshold
    ~ __private__challengeEffortProgress = 0
    ~ __private__hasPlayerDisengaged = false

    // 1 is a magic number - this is the first time this recursive method is being called
    -> __private__challengeCheckWithEffortRecursive(1, challengeType.safe, target_difficulty, required_effort, maximum_tries, applicable_trait, applicable_concepts, applicable_perks, applicable_quirks) ->
    
    {showDebugMessages:{__private__challengeEffortProgress} < {required_effort}? {__private__challengeEffortProgress < required_effort}}
    
    {
    - __private__challengeEffortProgress < required_effort:
        ->-> goto_failure
    }

    ->->

// standard effort-based challenge checks (like combat) remove resolve when you fail the roll
=== challengeCheckWithEffortVersusResolve(target_difficulty, required_effort, applicable_trait, applicable_concepts, applicable_perks, applicable_quirks, -> goto_disengage, -> goto_failure)

    // effort counts up from 0 to required_effort threshold
    ~ __private__challengeEffortProgress = 0
    ~ __private__hasPlayerDisengaged = false
    
    // 1 is a magic number - this is the first time this recursive method is being called
    -> __private__challengeCheckWithEffortRecursive(1, challengeType.dangerous, target_difficulty, required_effort, 0, applicable_trait, applicable_concepts, applicable_perks, applicable_quirks) ->
    
    {showDebugMessages:{__private__challengeEffortProgress} < {required_effort}? {__private__challengeEffortProgress < required_effort}}
    
    {
    - __private__hasPlayerDisengaged:
        ->-> goto_disengage

    - __private__challengeEffortProgress < required_effort:
        ->-> goto_failure
    }

    ->->

=== challengeCheck (target_difficulty, applicable_trait, applicable_concepts, applicable_perks, applicable_quirks, -> goto_failure, -> goto_crit_failure)

    // target_difficulty has been converted to challengeDifficulty in setup; nothing else should use target_difficulty
    -> __private__challengeRollSetup(target_difficulty, applicable_quirks) ->

    // do the roll, considering concepts and perks
    -> __private__doOneChallengeRoll(applicable_trait, applicable_concepts, applicable_perks) ->
    
    // short circuit if the resolution is not favorable
    { challengeResolution:
    - criticalFailure:
        ->-> goto_crit_failure
    - failure:
        ->-> goto_failure
    }

    ->->
