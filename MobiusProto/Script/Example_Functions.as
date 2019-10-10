/*
 * Script functions declared with UFUNCTION() above them will be exposed
 * to unreal. For global functions, this means they will be directly
 * accessible as blueprint nodes.
 */

/*
	The comment directly above the function will be used as a tooltip
	for the blueprint node.

	Note the 'Category = ' specifier in the UFUNCTION() description,
	which will determine the heading the function is under in the
	blueprint menu.
*/
UFUNCTION(Category = "Example Functions")
void ExecuteExampleFunction(AActor InputActor)
{
	Print("Printed on screen");

	// Hides the specified actor when this function is called
	InputActor.ActorHiddenInGame = true;
}