import GameFiles.MMobiusGameMode;

class ACustomCamera : ACameraActor
{
    APawn PlayerRef;

    AMobiusGameMode GameMode;

    float ZOffset = 600;
    float XOffset = -1900;
    float YRotation = -20;
    
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        FRotator StarRot = FRotator(YRotation, 0, 0); 
        SetActorRotation(StarRot);
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        if (PlayerRef != nullptr)
        {
            float YLerp = FMath::Lerp(GetActorLocation().Y, PlayerRef.GetActorLocation().Y, 0.1f);
            YLerp *= 0.9f;
            FVector StartLoc = FVector(PlayerRef.GetActorLocation().X + XOffset, YLerp, PlayerRef.GetActorLocation().Z + ZOffset);
            SetActorLocation(StartLoc);
        }
    }

    UFUNCTION()
    void SetPlayerReference(APawn OurPawn)
    {
        PlayerRef = OurPawn;

        if (PlayerRef != nullptr)
        {
            Print("Player Reference Set",5);
        }
    }

    UFUNCTION()
    void SetGameModeReference()
    {
        GameMode = Cast<AMobiusGameMode>(Gameplay::GetGameMode()); 
        
        if (GameMode != nullptr)
        {
            Print("We found game mode", 5);

            GameMode.EventSetPlayerReference.AddUFunction(this, n"SetPlayerReference");
        }
    }
}