


using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{

    public CharacterController controller;
    [SerializeField] Animator animator;
    public float speed = 12f;
    public float sprintModifier = 2f;
    public float gravity = -10f;
    public float jumpHeight = 2f;

    public Transform groundCheck;
    public float groundDistance = 0.4f;
    public LayerMask groundMask;


    Vector3 velocity;
    bool isGrounded;


    [SerializeField] float sensitivity = 10;
    // Update is called once per frame
    void Update()
    {
        float x;
        float z;
        bool jumpPressed = false;
        Savemanager.currentSave.playerPosition = transform.position;

        transform.eulerAngles = new Vector3(transform.eulerAngles.x, Camera.main.transform.eulerAngles.y, transform.eulerAngles.z);


        x = Input.GetAxis("Horizontal");
        z = Input.GetAxis("Vertical");
        jumpPressed = Input.GetButtonDown("Jump");
        Vector2 norm = new Vector2(x, z).normalized;
        x = norm.x;
        z = norm.y;

        isGrounded = Physics.CheckSphere(groundCheck.position, groundDistance, groundMask);

        if (isGrounded && velocity.y < 0)
        {
            velocity.y = -2f;
        }

        if (isGrounded)
        {
            animator.SetBool("Falling", true);
        }
        else animator.SetBool("Falling", false);


        float modifier = Input.GetButton("Sprint") ? sprintModifier : 1;

        z *= modifier;
        Vector3 move = transform.right * x + transform.forward * z;
        controller.Move(move * speed * Time.deltaTime);

        float animModifier = Input.GetButton("Sprint") ? 2 : 1;
        animator.SetFloat("Walk", (z / 2) * animModifier);
        animator.SetFloat("Strafe", x);

        if (jumpPressed && isGrounded)
        {
            velocity.y = Mathf.Sqrt(jumpHeight * -2f * gravity);
        }

        velocity.y += gravity * Time.deltaTime;

        controller.Move(velocity * Time.deltaTime);
    }
    private void Start()
    {
        if (Checkpoint.LastCheckpoint != null)
        {
            GetComponent<CharacterController>().enabled = false;
            transform.position = Checkpoint.LastCheckpoint.transform.position;
            GetComponent<CharacterController>().enabled = true;
        }
    }


}
