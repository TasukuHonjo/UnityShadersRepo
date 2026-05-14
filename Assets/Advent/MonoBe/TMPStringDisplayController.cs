using UnityEngine;

public class TMPStringDisplayController : MonoBehaviour
{
    private TMPStringDisplay currentBehaviour;

    public void SetCurrentBehaviour(TMPStringDisplay behaviour)
    {
        currentBehaviour = behaviour;
    }

    public void Skip()
    {
        currentBehaviour?.Skip();
    }
}
