using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.InputSystem;

public class Hoge : MonoBehaviour
{
    public PlayableDirector director;
    public TMPStringDisplayController tMPStringDisplayController;

    

    void Awake()
    {
        director.Stop();
    }

    void Update()
    {
        if (Keyboard.current.eKey.wasPressedThisFrame)
        {
            director.Play();
        }

        if (Keyboard.current.spaceKey.wasPressedThisFrame && director.state == PlayState.Playing)
        {
            Debug.Log("Skip");
            tMPStringDisplayController.Skip();
        }
    }
}
