import AMobiusGameMode;
import AMainPlayer;

enum EObstacleType {Block, Breakable, Healing, Point} 
enum EObstacleState {Static, Moving}

class AObstacle : AActor 
{
    UPROPERTY()
    EObstacleType ObstacleType;

    UPROPERTY()
    AMobiusGameMode GameMode;

    UPROPERTY(DefaultComponent, RootComponent)
    USceneComponent SceneComp;

    UPROPERTY()
    UMaterial MatBlock;
    UPROPERTY()
    UMaterial MatBreak;
    UPROPERTY()
    UMaterial MatHeal;

    UPROPERTY()
    TSubclassOf<AActor> PickUpType;
    AActor PickUpRef;

    UPROPERTY()
    TSubclassOf<AActor> HealthPickUpType;
    AActor HealthPickUpRef;

    UPROPERTY(DefaultComponent, Attach = SceneComp)
    UBoxComponent BoxCollision;
    default BoxCollision.SetCollisionEnabled(ECollisionEnabled::QueryOnly);
    default BoxCollision.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);
    default BoxCollision.SetCollisionResponseToChannel(ECollisionChannel::ECC_Pawn, ECollisionResponse::ECR_Overlap);
    default BoxCollision.SetCollisionResponseToChannel(ECollisionChannel::ECC_Vehicle, ECollisionResponse::ECR_Overlap);

    UPROPERTY(DefaultComponent, Attach = SceneComp)
    UStaticMeshComponent MeshComp;
    default MeshComp.SetCollisionResponseToAllChannels(ECollisionResponse::ECR_Ignore);
    default MeshComp.StaticMesh = Asset("/Engine/BasicShapes/Cube.Cube");
    default MeshComp.SetWorldScale3D(FVector(4));
    default BoxCollision.SetBoxExtent(MeshComp.GetBoundingBoxExtents()); 

    UPROPERTY()
    float MovementSpeed = 3000; //GameMode.GlobalMovementSpeed;

    UPROPERTY()
    float SideSpeed = 2000;

    float yMin = -1000;
    float yMax = 1000;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        GameMode = Cast<AMobiusGameMode>(Gameplay::GetGameMode());
        MovementSpeed = GameMode.GlobalMovementSpeed;

        BoxCollision.OnComponentBeginOverlap.AddUFunction(this, n"TriggerOnBeginOverlap");

        GameMode.EventSpeedIncrease.AddUFunction(this, n"MatchGlobalSpeed");
        GameMode.EventHaltSpeed.AddUFunction(this, n"MatchGlobalSpeed");

    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds)
    {
        MoveObject(DeltaSeconds);
        if (GetActorLocation().X <= - 10500)
        {
            DestroyActor();
        }
    }

    UFUNCTION()
    void TriggerOnBeginOverlap(
        UPrimitiveComponent OverlappedComponent, AActor OtherActor,
        UPrimitiveComponent OtherComponent, int OtherBodyIndex, 
        bool bFromSweep, FHitResult& Hit) 
    { 
        AMainPlayer Player = Cast<AMainPlayer>(OtherActor);

        if(Player != nullptr && ObstacleType != EObstacleType::Point) 
        {
            Player.DamagePlayer(1);

            Print("" + Player.Health, 5);
            
            if (Player.Health <= 0) 
            {
                GameMode.HaltSpeed();
                Player.IsAlive = false;
                GameMode.CanScore = false;
            }
            else 
            {
                DestroyActor();
            }
            // if (ObstacleType == EObstacleType::Block)
            // {

            // }
            // else  if (ObstacleType == EObstacleType::Breakable)
            // {
            //     DestroyActor();
            //     Print("Breakable Gives Points",5);
            //     //Spawn Pick Up that will add points
            // }
        }
    }

    UFUNCTION()
    void ObstacleTypeDeclared(EObstacleType ObsType)
    {
        if (ObsType ==  EObstacleType::Block)
        {
            ObstacleType = EObstacleType::Block;
            MeshComp.SetMaterial(0, MatBlock);
        }
        else if (ObsType ==  EObstacleType::Breakable)
        {
            ObstacleType = EObstacleType::Breakable;
            MeshComp.SetMaterial(0, MatBreak);
        }
        else if (ObsType ==  EObstacleType::Healing)
        {
            ObstacleType = EObstacleType::Healing;
            MeshComp.SetMaterial(0, MatHeal);
        }
    }

    UFUNCTION()
    void ObstacleProjectileResponse()
    {   
        if (ObstacleType == EObstacleType::Breakable)
        {
            PickUpRef = SpawnActor(PickUpType, GetActorLocation() + FVector(0,0,100));
            DestroyActor();
        }
        else if (ObstacleType == EObstacleType::Healing)
        {
            HealthPickUpRef = SpawnActor(HealthPickUpType, GetActorLocation() + FVector(0,0,100));
            DestroyActor();
        }
    }

    UFUNCTION()
    void MatchGlobalSpeed()
    {
        // Print("Delegate bind called for objects", 5);
        // Print("Obstacle Match Global Speed Event Recieved", 5);
        MovementSpeed = GameMode.GlobalMovementSpeed;
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
    void MoveSide()
    {

    }
}