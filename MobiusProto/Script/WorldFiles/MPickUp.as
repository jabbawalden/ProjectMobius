import GameFiles.MMobiusGameMode;
import WorldFiles.MProjectile;
import WorldFiles.MMovementComp;

class APickUp : AActor
{
    AMobiusGameMode GameMode;

    float RotateSpeed = 300;

    float MovementSpeed;

    UPROPERTY(DefaultComponent)
    UMovementComp MovementComp;

    UPROPERTY(DefaultComponent, RootComponent)
    USphereComponent SphereComp;

    UPROPERTY(DefaultComponent, Attach = SphereComp)
    UStaticMeshComponent MeshComp;
    
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        GameMode = Cast<AMobiusGameMode>(Gameplay::GetGameMode());

        if (GameMode != nullptr)
        {
            MovementSpeed = GameMode.GlobalMovementSpeed;
            // GameMode.EventSpeedIncrease.AddUFunction(this, n"MatchGlobalSpeed");
            // GameMode.EventHaltSpeed.AddUFunction(this, n"MatchGlobalSpeed");
        }
        SphereComp.OnComponentBeginOverlap.AddUFunction(this, n"TriggerOnBeginOverlap");
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds) 
    {
        RotatePickUp(DeltaSeconds);
        //MovePickUp(DeltaSeconds);

        if (GetActorLocation().X <= - 10500)
        {
            DestroyActor();
        }
    }

    UFUNCTION()
    void RotatePickUp(float DeltaSeconds)
    {
        FRotator CurrentRot = GetActorRotation();
        FRotator NextRot = CurrentRot += FRotator(0, 0, -RotateSpeed * DeltaSeconds);
        SetActorRotation(NextRot);
    }

    // UFUNCTION()
    // void MovePickUp(float DeltaSeconds)
    // {
    //     FVector CurrentLoc = GetActorLocation();
    //     FVector NextLoc = CurrentLoc += FVector(-MovementSpeed * DeltaSeconds, 0, 0);
    //     SetActorLocation(NextLoc);
    // }

    //call when overlapping
    UFUNCTION()
    void CallAddPoints()
    {
        if (GameMode != nullptr)
        {
            GameMode.AddPoints();
        }

    }

    // UFUNCTION()
    // void MatchGlobalSpeed()
    // {
    //     MovementSpeed = GameMode.GlobalMovementSpeed;
    // }

    UFUNCTION()
    void TriggerOnBeginOverlap(
        UPrimitiveComponent OverlappedComponent, AActor OtherActor,
        UPrimitiveComponent OtherComponent, int OtherBodyIndex, 
        bool bFromSweep, FHitResult& Hit) 
    {
        AMainPlayer PlayerRef = Cast<AMainPlayer>(OtherActor);
        
        if (PlayerRef != nullptr)
        {
            CallAddPoints();
            DestroyActor();
        }
    }

}