import WorldFiles.MObstacle;

class AProjectile : AActor
{
    UPROPERTY()
    float ProjSpeed = 27000;

    UPROPERTY()
    float DestroyTime = 0.65f;
    float CurrentTimer;

    UPROPERTY(DefaultComponent, RootComponent)
    USphereComponent SphereComp;
    default SphereComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Overlap);
    // default SphereComp.SetCollisionResponseToChannel(ECollisionChannel::ECC_WorldDynamic, ECollisionResponse::ECR_Overlap);
    default SphereComp.SetCollisionObjectType(ECollisionChannel::ECC_Vehicle);

    UPROPERTY(DefaultComponent, Attach = SphereComp)
    UStaticMeshComponent SphereMesh;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        SphereComp.OnComponentBeginOverlap.AddUFunction(this, n"TriggerOnBeginOverlap");
        CurrentTimer = Gameplay::TimeSeconds + DestroyTime;
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        MoveProjectile(DeltaSeconds);
        if (Gameplay::TimeSeconds >= CurrentTimer)
        {
            DestroyActor();
        }
    }

    UFUNCTION()
    void MoveProjectile(float DeltaSeconds) 
    {
        FVector CurrentLoc = GetActorLocation();
        FVector NextLoc = CurrentLoc += FVector(ProjSpeed * DeltaSeconds, 0, 0);
        // Print("Level Loc is " + NextLoc, 5);
        SetActorLocation(NextLoc);
    }

    UFUNCTION()
    void TriggerOnBeginOverlap(
        UPrimitiveComponent OverlappedComponent, AActor OtherActor,
        UPrimitiveComponent OtherComponent, int OtherBodyIndex, 
        bool bFromSweep, FHitResult& Hit) 
    {

        AObstacle ObstacleRef = Cast<AObstacle>(OtherActor);

        if (ObstacleRef != nullptr && ObstacleRef.ObstacleType != EObstacleType::Point)
        {
            ObstacleRef.ObstacleProjectileResponse();
            DestroyActor();
        }
    }
}