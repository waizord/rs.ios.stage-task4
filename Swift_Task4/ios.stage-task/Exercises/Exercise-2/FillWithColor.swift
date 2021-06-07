import Foundation

final class FillWithColor {
    
    func fillWithColor(_ image: [[Int]], _ row: Int, _ column: Int, _ newColor: Int) -> [[Int]] {
        if image.isEmpty {
            return []
        }
        
        if row < 0 || column < 0 {
            return image
        }
        
        if row >= image.count || column >= image[0].count {
            print(image)
            return image
        }
        
        if newColor == image[row][column] {
            return image
        }
        var newImage = image
        
        func check(_ i: Int, _ j: Int, _ color: Int) {
            if newImage[i][j] != color {
                return
            }
            newImage[i][j] = newColor
            if i != 0 {
                check(i-1, j, color)
            }
            if i != image.count-1{
                check(i+1, j, color)
            }
            if j != 0{
                check(i, j-1, color)
            }
            if j != image[0].count-1{
                check(i, j+1, color)
            }
        }
        
        check(row, column, newImage[row][column])
        
        return newImage
    }
}
