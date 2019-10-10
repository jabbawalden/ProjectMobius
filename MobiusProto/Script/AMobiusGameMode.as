event void FSpeedDifficultyIncrease(); 
event void FHaltSpeed();

class AMobiusGameMode : AGameModeBase
{
    float GlobalMovementSpeed = 9000;
    float SpeedIncreaseAmount = 700;
    // float PlayerSpeed = 4870000000.0f;

    int MaxHealthRef = 3;
    int HealthRef = 3;

    bool GameStarted = false;
    bool CanScore = true;

    FSpeedDifficultyIncrease EventSpeedIncrease; 
    FHaltSpeed EventHaltSpeed;

    // UPROPERTY()
    // TArray<AActor> SpawnedLevels;

    UPROPERTY()
    float PointRate = 0.1f;

    UPROPERTY()
    float NewTime;

    //when array is above 2, delete the first element and remove from array

    UPROPERTY()
    int Points;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        //Print(" " + GlobalMovementSpeed, 5);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        //Print(" " + GlobalMovementSpeed, 5);
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