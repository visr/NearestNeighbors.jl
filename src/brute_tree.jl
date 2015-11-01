immutable BruteTree{T <: AbstractFloat, P <: Metric} <: NNTree{T, P}
    data::Matrix{T}
    metric::P
    leafsize::Int
    reordered::Bool
end

"""
    BallTree(data [, metric = Euclidean()) -> brutetree

Creates a `BruteTree` from the data using the given `metric`.
"""
BruteTree{T <: AbstractFloat}(data::Matrix{T}, metric::Metric=Euclidean()) = BruteTree(data, metric, 0, false)
#BruteTree{T <: AbstractFloat, P<:Metric}(data::Matrix{T}, metric::P) = BruteTree(data, metric)

function _knn{T <: AbstractFloat}(tree::BruteTree{T},
                                  point::AbstractVector{T},
                                  k::Int)
    best_idxs = [-1 for _ in 1:k]
    best_dists = [typemax(T) for _ in 1:k]
    knn_kernel!(tree, point, best_idxs, best_dists)
    return best_idxs, best_dists
end

function knn_kernel!{T <: AbstractFloat}(tree::BruteTree{T},
                                         point::AbstractArray{T},
                                         best_idxs::Vector{Int},
                                         best_dists::Vector{T})

    for i in 1:size(tree.data, 2)
        @POINT 1
        dist_d = evaluate(tree.metric, tree.data, point, i)
        if dist_d <= best_dists[1]
            best_dists[1] = dist_d
            best_idxs[1] = i
            percolate_down!(best_dists, best_idxs, dist_d, i)
        end
    end
end

function _inrange{T}(tree::BruteTree{T},
                    point::AbstractVector{T},
                    radius::T)
    idx_in_ball = Int[]
    inrange_kernel!(tree, point, radius, idx_in_ball)
    return idx_in_ball
end


function inrange_kernel!{T <: AbstractFloat}(tree::BruteTree{T},
                                            point::Vector{T},
                                            r::T,
                                            idx_in_ball::Vector{Int})
    for i in 1:size(tree.data, 2)
        @POINT 1
        d = evaluate(tree.metric, tree.data, point, i)
        if d <= r
            push!(idx_in_ball, i)
        end
    end
end