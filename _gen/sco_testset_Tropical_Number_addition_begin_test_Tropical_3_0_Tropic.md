
```language-julia
@testset "Tropical Number addition" begin
	@test Tropical(3.0) + Tropical(2.0) == Tropical(3.0)
	@test_throws BoundsError [1][2]
	@test_broken 3 == 2
end
```


```output
Test.DefaultTestSet("Tropical Number addition", Any[Test Broken
  Expression: 3 == 2], 2, false, false, true, 1.708268439682298e9, 1.708268439693213e9, false, "none")
```



