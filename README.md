# Foliage3D

Procedural foliage generation for Terrain3D.

![](./screenshot.png)

**Important**: This addon is in alpha, bugs and breaking changes are to be expected. Always back up your project.

## Getting started

After enabling the plugin, create a *Foliage3D* node below a *Terrain3D* node.
To set bounds, create a *CollisionShape3D* node below *Foliage3D* with either a box or sphere shape
(this will likely be replaced with a custom node in the future).

Once bounds are set, create a graph. Saving to disk is optional but recommended. The graph editor opens in the bottom panel.
Create a *SurfaceSampler* node by right-clicking anywhere and feed its
output into a *MeshSpawner* node. To assign a mesh, click on the *MeshSpawner* and add at least one mesh in the sidebar on the right.
This should spawn meshes in the 3D viewport. Click the save button under *Foliage3D* to save the meshes into your terrain data, or clear to delete them.

## Performance

This plugin uses threads and should perform decently up to a certain size.
A bounding box is drawn around all shapes, therfore it is recommended to only use shapes in close proximity to each other.
Creating a very large number of points (e.g. to spawn grass) and comparing them with e.g. the *Difference* or *Prune* nodes will take considerable time.

A C++ rewrite of core nodes has been put on hold because I am not an experienced C++ programmer
and I have concerns that it will deter potential contributors.

## Nodes

#### SurfaceSampler

Sample points from terrain surface within bounds. Point extents sets a bounding box that, for example, can be used to filter overlapping points with the *Difference* and *Prune* nodes.

#### FilterPoint

Filter point position and rotation range. A `0` value equals the respective minimum/maximum value.

#### Transform

Randomize transform offset/rotation/scale.

#### Difference

Remove points in A that overlap with B.

#### Prune

Remove points that overlap with self.

#### MeshSpawner

Spawn meshes.
