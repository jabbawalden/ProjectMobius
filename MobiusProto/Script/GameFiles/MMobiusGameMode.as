event void FSpeedDifficultyIncrease(); 
event void FHaltSpeed();
event void FSetPlayerReference(APawn OurPawn);

class AMobiusGameMode : AGameModeBase
{
    float GlobalMovementSpeed = 10000;
    float SpeedIncreaseAmount = 1000;
    // float PlayerSpeed = 4870000000.0f;

    int MaxHealthRef = 3;
    int HealthRef = 3;

    bool GameStarted = false;
    bool CanScore = true;

    FSpeedDifficultyIncrease EventSpeedIncrease; 
    FHaltSpeed EventHaltSpeed;
    FSetPlayerReference EventSetPlayerReference; 

    UPROPERTY()
    float PointRate = 0.1f;

    UPROPERTY()
    float NewTime;

    UPROPERTY()
    int Points;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {

    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        ScorePoints();
    }

    UFUNCTION()
    void ScorePoints()
    {
        if (NewTime <= Gameplay::TimeSeconds && CanScore)
        {
            Points++;
            NewTime = Gameplay::TimeSeconds + PointRate;
        }
    }

    UFUNCTION()
    void AddPoints()
    {
        Points += 50;
    }

    UFUNCTION()
    void HaltSpeed()
    {
        GlobalMovementSpeed = 0;
        EventHaltSpeed.Broadcast();
    }

    UFUNCTION()
    void CallIncreaseSpeedDelegate()
    {
        GlobalMovementSpeed += SpeedIncreaseAmount;
        SpeedIncreaseAmount *= 0.95f;
        // PlayerSpeed *= 2;
        // Print("GM P Speed: " + PlayerSpeed, 5);
        EventSpeedIncrease.Broadcast();
    }

}