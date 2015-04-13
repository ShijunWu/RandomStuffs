/*
* Question:
*   To build a panel using 3”×1” and 4.5”×1" blocks. For structural integrity, the spaces between the blocks
*   must not line up in adjacent rows. For example, the 13.5”×3” panel below is unacceptable, because
*   some of the spaces between the blocks in the first two rows line up.
*   |---4.5---|---3--|---3--|---3--|
*   |---3--|---3--|---4.5---|---3--|
*   |---4.5---|---4.5---| ---4.5---|
*
*   There are 2 ways in which to build a 7.5”×1” panel, 2 ways to build a 7.5”×2” panel, 4 ways to build a
*   12”×3” panel, and 7958 ways to build a 27”×5” panel. How many different ways are there for your niece to
*   build a 48”×10” panel? The answer will fit in a 64-bit integer. Write a program to calculate the answer.
*
*   The program should be non-interactive and run as a single-line command which takes two command-line
*   arguments, width and height, in that order. Given any width between 3 and 48 that is a multiple of 0.5,
*   inclusive, and any height that is an integer between 1 and 10, inclusive, your program should calculate
*   the number of valid ways there are to build a wall of those dimensions.
*/

/*
 * Author: Shijun Wu
 *
 * To run the program, run the following command
 *      javac BlockPuzzle.java
 *      java BlockPuzzle x y
 * Where x should be number range between 3 and 48 that is a multiple of 0.5, inclusive.
 * Where y should be integer range between between 1 and 10, inclusive.
 *
 *
 * One way to solve the problem is enumerating all the possible combination by recursively add a block
 *    to the panel and check the new block fits the rule. If not fit, get back to previous position
 *    and try other block. If a row finish, then get to the next row and so on. But this will takes
 *    very long time since there are too many duplicate row combination will be try out again and again.
 *
 * We can reduce the time by eliminating the try for duplicate row combination.
 * First, find out all the combinations to build a panel with giving width and height 1.
 *    If there are n ways to build a panel with giving width and height 1, that means there are n way to
 *    build each row if want to build a panel with height greater than 1. But this is the case
 *    without the rule: spaces between the blocks must not line up in adjacent rows.
 * Second, after find out how many combination to form a row, next step is for each combination, find out
 *    how many combinations can be placed adjacent to the combination that obey the rule
 * Finally, find out the result using bottom up dynamic programming.
 *    To build panel with height h:
 *        Assume using combination A as the first row, lets assume A has 2 fit adjacent rows combinations B and C
 *        Assume there are x ways to build a panel with height h - 1 with B as the first row,
 *        and there are y ways to build a panel with height h - 1 with C as the first row.
 *    Then the number of way to build a panel with height h with A as first row is x + y.
 *        Since already have one row A, we need h - 1 more row to reach h.
 *        The possible adjacent rows to A is B and C,
 *            If use B for the next row, then it is 1 row of A + (h - 1) rows build from B (treat B as the first row)
 *            And we know that B has x ways to build height of h - 1, so we have x ways to build height h with A as the
 *            first row and B as second row.
 *            If use C for the next row, then it is 1 row of A + (h - 1) rows build from C (treat C as the first row)
 *            And we know that C has y ways to build height of h - 1, so we have y ways to build height h with A as the
 *            first row and C as second row.
 *        Theregore the result is x + y.
 *
 * Therefore, for any height h, to build a panel with width w
 *    Number of way to build the panel = (a1 + a2 + a3 + a4 + ... + an)
 *        n is the number of possible combinations to build one row with width w
 *        a1 ... an, is the number of ways to build a panel with height h for each combination as first row
 *
 * The result is 806844323190414
 * The runtime is O(2^n), where n is the width
 */
import java.util.ArrayList;
import java.lang.annotation.*;
import java.util.Arrays;
import java.util.List;

@Target(ElementType.TYPE)
@interface ProgramInfo {
  String author();
  String howToRun();
  String params();
}

@ProgramInfo(
  author = "Shijun Wu",
  howToRun = "java BlockPuzzle x y",
  params = "x - width (double, 3 to 48, multiple of 0.5), y - height (int, 1 to 10)"
)
public class BlockPuzzle {
  public static class BlockPanel {
    private final double BLOCK1 = 3;
    private final double BLOCK2 = 4.5;

    private int height;
    private double width;

    /*
     * The ArrayList that hold the array for space lines
     * Each element of the ArrayList is an array of space lines for one combination of two kinds of
     *    blocks that form a panel with giving width and height 1
    */
    private ArrayList<Double []> spaceLines = new ArrayList<Double []>();

    /*
     * Each element of the ArrayList is the array that hold the index of combinations in spaceLines that can build
     *    next to the current combination
     * The index of fitNeighbours corresponding to the position in the spaceLines, that means each index
     *    refers to one type of combination
    */
    private ArrayList<Integer []> fitNeighbours = new ArrayList<Integer []>();

    public BlockPanel(double width, int height) {
      this.width = width;
      this.height = height;
    }

    public void setPanelWidth(double width) {
      this.width = width;
    }

    public double getPanelWidth() {
      return this.width;
    }

    public void setPanelHeight(int height) {
      this.height = height;
    }

    public double getPanelHeight() {
      return this.height;
    }

    public boolean checkDimensions(){
      if(this.height <= 0 || this.height > 10){
        System.out.println("Height need to be between 1 - 10 inclusive.");
        return false;
      }
      if(this.width <= 3 || this.width > 48 || this.width % 0.5 > 0){
        System.out.println("Width need to be between 3 and 48 that is a multiple of 0.5, inclusive.");
        return false;
      }

      return true;
    }

    /*
     * This method will enumerate all the combinations to build the panel with giving width and height 1
     *    using the 2 types of blocks
     * Each combination will be represented as an array of space lines instead of the block used - for
     *    example: If we use 1 block with width 3 and 1 block with width 4.5 to build a 7.5*1 panel,
     *    and there are two way to build the panel, we can represent this 2 ways as two one element array:
     *    3 and 4.5, where the starting and ending will be omitted.
     * The algorithm of this method is by try to add a new block to the current combination, if the block
     *    fits, the method will recursive call the method itself to add new block. When we fail add a block
     *    for the current position, the method will recursive back to the last position and try another block and
     *    so on.
     *
     * tempSpaceLines - use to hold the temporary space lines since some combination not works, we only
     *    add the combination that works to the result. I use ArrayList here since we don't know the
     *    how many block we will use for each combination.
     */
    private void findSpaceLines(double currentWidth, ArrayList<Double> tempSpaceLines) {
      if (this.width == 0)
        return;
      /*
       * The base condition: if we reach the target width, that means the current combination works,
       *    so add the combination to the ArrayList
       */
      if (this.width == currentWidth) {
        //Convert the ArrayList to array
        Double [] a  = new Double[tempSpaceLines.size()];
        tempSpaceLines.toArray(a);
        spaceLines.add(a);
        return;
      }

      //Both are recursive cases: try to add block with width 3 and 4.5
      addBlocks(BLOCK1, currentWidth, tempSpaceLines);
      addBlocks(BLOCK2, currentWidth, tempSpaceLines);
    }

    private void addBlocks(double blockSize, double currentWidth, ArrayList<Double> tempSpaceLines) {
      if (currentWidth + blockSize <= this.width) {
        //check the remaining space is greater than either kind of block or is 0
        double remainingWidth = this.width - (currentWidth + blockSize);
        if (remainingWidth >= BLOCK1 || remainingWidth >= BLOCK2 || remainingWidth == 0) {

          double temWidth = currentWidth + blockSize;
          //Adding space line, exclusive for the ending
          if (temWidth != width) {
            tempSpaceLines.add(new Double(temWidth));
          }
          //Recursively call the method with increased currentWidth(temWidth here)
          findSpaceLines(temWidth, tempSpaceLines);
          //Since get back to the current position without adding any block, so need to remove the last block
          if (tempSpaceLines.size() >= 1 && temWidth != this.width) {
            tempSpaceLines.remove(tempSpaceLines.size() - 1);
          }
        }
      }
    }

    /*
     * This method is find all the other combination that can place next to a combination and store
     *    the result as an Array in the ArrayList
     * The method will do the above operation for all the combinations
     */
    private void findFitNeighbour() {
      Double[] tempSpaceLines;
      ArrayList<Integer> tempfitNeighbour = new ArrayList<Integer> ();

      //Go over each combination
      for (int i = 0; i < spaceLines.size(); i++) {
        //Get the current combination
        tempSpaceLines = spaceLines.get(i);
        // The case that combination that only have one block
        if (tempSpaceLines.length == 0) {
          tempfitNeighbour.add(i);
        }
        //Go over each combination and check whether they fit the rule, if so , add to tempfitNeighbour
        for (int j = 0; j < spaceLines.size(); j++) {
          //not checking current combination itself
          if (i == j) {
            continue;
          }
          if (checkFit(tempSpaceLines, spaceLines.get(j))) {
            tempfitNeighbour.add(j);
          }
        }

        //Convert the ArrayList to array
        Integer[] temfitN = new Integer[tempfitNeighbour.size()];
        tempfitNeighbour.toArray(temfitN);
        fitNeighbours.add(temfitN);//add to result
        tempfitNeighbour.clear();
      }
    }

    /*
     * This method is to check whether 2 combinations can place next to each other without breaking the rule
     */
    private static boolean checkFit(Double[] com1, Double[] com2) {
      List<Double> list2 = Arrays.asList(com2);

      for (int i = 0; i < com1.length; i++) {
        double tempg = com1[i];
        if (list2.contains(tempg)) {
          return false;
        }
      }
      return true;
    }

    //The method that solve the puzzle
    public long solveBlockPuzzle(double width, int height) {
      if(checkDimensions()){
        // Find all the combinations first
        findSpaceLines(0, new ArrayList<Double>());
        // Find the adjacent conbinations for each combination
        findFitNeighbour();

        return calculateCombiantion();
      }
      return 0;
    }

    /*
     * The method calculate the final result
     * The method use dynamic programming methodology to calculate the result.
     *  I use bottom up method, starting from height 1 to target height
     *  For height 1, each combination only have one combination, therefore, it is 1
     *  For height 2, for a particular combination as base, the possible combinations to build a panel
     *    with height 2 base on that base is the sum of the number of combination for the fit neighbors
     *    at height 1 for that particular combination. For example: combination a has two fit neighbors
     *    b and c. Since for height 1, each combination have value 1, therefore, for height 2 that build
     *    on a, the number of combination is the sum of value for b and c at height 1, which is 1+1 = 2
     *  For height n, the possible combination with a giving base combination is the sum of its fit
     *    neighbors's value at height - 1. For example: a has 3 fit neighbors b, c, and d. To build a
     *    panel with height 10, the possible combination is the sum of the value for b, c, and d at
     *    height 9. Assume b has 100 combinations to build panel with height 9, c has 50, and d has 200.
     *    Then the num of combination to build a panel with height 10 with a as the first row is
     *    100+50+200=350 (a is the first row + 9 rows of its neighbor).
     */
    private long calculateCombiantion() {
      //the matrix to hold the value for each height of each combination
      //I use 1 to height as index for the second dimension for convenience
      long[][] matrix = new long[fitNeighbours.size()][height + 1];

      //Loop from height 1 to target height
      for (int currentH = 1; currentH <= height; currentH++) {
        // If its height one, there's only one possible way to build the panel for each combination which is themselves
        if (currentH == 1) {
          for (int i = 0; i < matrix.length; i++) {
            matrix[i][1] = 1;
          }
        } else {
          //Form of 2 to target height, loop over each combination
          for (int i = 0; i < matrix.length; i++) {
            //get the fit neighbours
            Integer[] fitNs = fitNeighbours.get(i);
            long count = 0;
            //Sum up the value at height - 1 for fit neighbours
            for (int a : fitNs) {
              count += matrix[a][currentH - 1];
            }
            matrix[i][currentH] = count;
          }
        }
      }

      //Sum up the last lvl, the result is the number of combination to build the panel with target width and height
      long result = 0;
      for (int i = 0; i < matrix.length; i++) {
        result += matrix[i][height];
      }
      return result;
    }
  }

  public static void main(String[] args) {
    if (args.length != 2) {
      System.out.println("The arugments are not correct, the argumens should be x and y - " +
                         "Where x should be number range between 3 and 48 that is a multiple of 0.5, inclusive. " +
                         "Where y should be integer range between between 1 and 10, inclusive.");
    } else {
      try {
        double width =  Double.parseDouble(args[0]);
        int height = Integer.parseInt(args[1]);
        BlockPanel bp = new BlockPanel(width, height);
        System.out.print(bp.solveBlockPuzzle(width, height));
      } catch (NumberFormatException exc) {
        System.out.print("The arugments are not correct, the argumens should be x and y - " +
                         "Where x should be number range between 3 and 48 that is a multiple of 0.5, inclusive. " +
                         "Where y should be integer range between between 1 and 10, inclusive.");
      }
    }
  }
}
