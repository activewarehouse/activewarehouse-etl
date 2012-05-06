---
layout: documentation
title: Documentation - Installation

current: Installation
---
# Installation

Integer sollicitudin erat vel lacus viverra et ullamcorper nunc gravida. Mauris pellentesque suscipit velit, id eleifend arcu scelerisque eu. Nunc luctus arcu id mauris hendrerit sed convallis orci pretium. Pellentesque dapibus enim non justo accumsan porttitor. Curabitur interdum nunc et dui tincidunt aliquet. In hac habitasse platea dictumst. Morbi eu mi nunc, vestibulum gravida nisi. Aliquam eu neque dolor.

Suspendisse potenti. Maecenas porta sem sed sapien imperdiet in sagittis velit bibendum. Nam molestie elit in eros fermentum sed sagittis nibh blandit. Aliquam facilisis bibendum quam sit amet eleifend. Duis pellentesque tristique iaculis. Pellentesque vitae nunc vitae leo rhoncus tempus nec vitae nisl. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Suspendisse id neque arcu. Donec ut malesuada dui. Sed quis nulla velit, vel ultricies leo. Vivamus sit amet sem massa. Praesent egestas eleifend purus ut consequat. Ut id dui neque, id interdum elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Suspendisse potenti. Fusce a libero dolor.

<div class="alert alert-block alert-notice">
  <h3>This topic is for advanced users</h3>
  <p>
    The following topic is for <em>advanced</em> users. The majority of Vagrant users
    will never have to know about this.
  </p>
</div>

Sed iaculis egestas enim, sit amet sodales nibh accumsan vitae. Aenean in augue urna. Ut pharetra, lectus nec tempor posuere, turpis neque aliquam dolor, id faucibus purus mi eget nisl. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. In justo lorem, facilisis et condimentum dignissim, viverra commodo nunc. Nam posuere libero in dui tincidunt at feugiat ligula condimentum. Proin pellentesque sagittis scelerisque. Donec viverra nulla id odio pellentesque vitae hendrerit diam interdum.

## Subtitle

Here we have a list:

* **DO SOMETHING** - something in bold likely

Then we have some `Inline::Code`:

{% highlight ruby %}
# Hello world
require 'common'

source :in, :file => 'something'

transform(:target_field) { |n,v,r| "3" }

destination :out
{% endhighlight %}
