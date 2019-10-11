import WorldFiles.MMainPlayer;
import GameFiles.MMobiusGameMode;
import GameFiles.MStatics;

class AHealingitem : AActor
{
    AMobiusGameMode GameMode;

    UPROPERTY()
    int HealthAmount = 1;

    UPROPERTY()
    float MovementSpeed;

    UPROPERTY(DefaultComponent, RootComponent)
    USphereComponent SphereComp;
    default SphereComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);
    default SphereComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn ,ECollisionResponse::ECR_Overlap);

    UPROPERTY(DefaultComponent, Attach = BoxComp)
    UStaticMeshComponent MeshComp;

    float ZStart;
    float ZMax;
    float ZAddToMax = 70;
    bool MovingUp = true;

    float BobbingSpeed = 70;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        ZStart = GetActorLocation().Z; 
        ZMax = ZStart + ZAddToMax;
        SphereComp.OnComponentBeginOverlap.AddUFunction(this, n"TriggerSphereOnOverlap");

        GameMode = Cast<AMobiusGameMode>(Gameplay::GetGameMode());

        if (GameMode != nullptr)
        {
            Print("Game Mode Found", 5);
            MovementSpeed = GameMode.GlobalMovementSpeed;
        }

        GameMode.EventSpeedIncrease.AddUFunction(this, n"MatchGlobalSpeed");
        GameMode.EventHaltSpeed.AddUFunction(this, n"MatchGlobalSpeed");
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        BallBob(DeltaSeconds);
        MoveObject(DeltaSeconds);

        if (GetActorLocation().X <= - 10500)
        {
            DestroyActor();
        }
    }

    UFUNCTION()
    void MoveObject(float DeltaSeconds)
    {   
        FVector CurrentLoc = GetActorLocation();
        FVector NextLoc = CurrentLoc += FVector(-MovementSpeed * DeltaSeconds, 0, 0);
        // Print("Level Loc is " + NextLoc, 5);
        SetActorLocation(NextLoc);
    }

    UFUNCTION()
    void BallBob(float DeltaSeconds)
    {

        if (GetActorLocation().Z <= ZStart)
        {
            MovingUp = true;
        }
        else if (GetActorLocation().Z >= ZMax)
        {
            MovingUp = false;
        }

        if (MovingUp)
        {
            FVector CurrentLoc = GetActorLocation();
            CurrentLoc.Z += BobbingSpeed * DeltaSeconds;
            SetActorLocation(CurrentLoc);
        }
        else
        {
            FVector CurrentLoc = GetActorLocation();
            CurrentLoc.Z -= BobbingSpeed * DeltaSeconds;
            SetActorLocation(CurrentLoc);
        }
    }

    UFUNCTION()
    void MatchGlobalSpeed()
    {
        MovementSpeed = GameMode.GlobalMovementSpeed;
    }

    UFUNCTION()
    void TriggerSphereOnOverlap (UPrimitiveComponent OverlappedComponent, AActor OtherActor,
    UPrimitiveComponent OtherComponent, int OtherBodyIndex, 
    bool bFromSweep, FHitResult& Hit)
    {
        AMainPlayer PlayerRef = Cast<AMainPlayer>(OtherActor);

        QP();

        if (PlayerRef != nullptr)
        {
            QP();
            if (PlayerRef.Health < PlayerRef.MaxHealth)
            {
                PlayerRef.HealPlayer(HealthAmount);
                DestroyActor();
            }
        }
    }


}