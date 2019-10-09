event void FSpeedDifficultyIncrease(); 
event void FHaltSpeed();

class AMobiusGameMode : AGameModeBase
{
    float GlobalMovementSpeed = 9000;
    float SpeedIncreaseAmount = 600;

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

        Print("Points: " + Points, 0);
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
        EventSpeedIncrease.Broadcast();
        GlobalMovementSpeed += SpeedIncreaseAmount;
        SpeedIncreaseAmount *= 0.95f;
    }

}