import GameFiles.MMobiusGameMode;
import GameFiles.MStatics;

class UMovementComp : UActorComponent
{
    AMobiusGameMode GameMode;

    float MovementSpeed = 3000;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        GameMode = Cast<AMobiusGameMode>(Gameplay::GetGameMode());

        if (GameMode != nullptr)
        {
            MovementSpeed = GameMode.GlobalMovementSpeed;
            GameMode.EventSpeedIncrease.AddUFunction(this, n"MatchGlobalSpeed");
            GameMode.EventHaltSpeed.AddUFunction(this, n"MatchGlobalSpeed");
        }
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        MoveObject(DeltaSeconds);
    }

    UFUNCTION()
    void MoveObject(float DeltaSeconds)
    {   
        FVector CurrentLoc = GetOwner().GetActorLocation();
        FVector NextLoc = CurrentLoc += FVector(-MovementSpeed * DeltaSeconds, 0, 0);
        // Print("Level Loc is " + NextLoc, 5);
        GetOwner().SetActorLocation(NextLoc);
    }

    UFUNCTION()
    void MatchGlobalSpeed()
    {
        MovementSpeed = GameMode.GlobalMovementSpeed;
    }

}