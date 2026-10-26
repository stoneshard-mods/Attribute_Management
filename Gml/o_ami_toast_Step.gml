y -= 0.4;
image_alpha -= 0.018;

if (image_alpha <= 0)
    instance_destroy();
